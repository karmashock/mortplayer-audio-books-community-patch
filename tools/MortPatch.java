// SPDX-License-Identifier: MIT
// MortPatch.java - the tiny patch tool used by the MortPlayer community patch kit.
//
// Why a custom tool instead of the usual "diff"/"patch" programs?
//   * A normal unified diff contains the lines it removes plus several lines of
//     surrounding context. For MortPlayer those would be lines of Mort's own
//     (closed-source) code, which we must not redistribute.
//   * Our ".mpatch" format never contains removed or context lines. Instead it
//     pins the exact file it expects by its SHA-256 checksum, so plain line
//     numbers are 100% safe: if the file is not byte-for-byte the expected one,
//     the tool stops before touching anything.
//   * It is plain Java, so it runs the same on Windows, macOS and Linux with the
//     Java you already need for apktool. Run it straight from source (Java 11+):
//         java MortPatch.java apply <patches-dir> <work-dir>
//
// Commands:
//   apply   <patches-dir> <work-dir>   apply every *.mpatch in name order
//   sha256  <file>                     print the checksum the tool would use
//   extract <zip/apk> <entry> <dest>   copy one entry out of a zip (no unzip needed)
//   copytree <src-dir> <dest-dir>      copy our new files into the project
//
// ---------------------------------------------------------------------------
// The .mpatch format (one text file = one logical fix)
//
//   # comment              lines starting with '#' (outside a hunk body) are notes for humans
//   project: app           which decoded tree to work in: "app" (apktool d -r) or "manifest" (full decode)
//   file: smali/x/Y.smali  the file to edit, relative to the project folder
//   sha256: <hex>          checksum the file MUST have right now (line endings normalised to \n)
//   replace 10-12          remove original lines 10..12 (their text is NOT stored here) ...
//   +new line              ... and put these lines in their place
//   insert-after 40        insert the following '+' lines after line 40 (0 = top of file)
//   +another new line
//   set: key value         (apktool.yml only) change the value of the single line "key: ..."
//
// Line numbers always refer to the file as it was BEFORE this patch section,
// so hunks are applied bottom-up and never disturb each other.
// ---------------------------------------------------------------------------

import java.io.*;
import java.nio.charset.StandardCharsets;
import java.nio.file.*;
import java.security.MessageDigest;
import java.util.*;
import java.util.zip.*;

public class MortPatch {

    /** One "replace"/"insert-after" instruction with the lines to put in. */
    static final class Hunk {
        int from, to;            // 1-based inclusive range to remove; to = from-1 means "insert only"
        final List<String> body = new ArrayList<>();
        int sourceLine;          // where in the .mpatch it came from, for error messages
    }

    /** All instructions for one target file inside one .mpatch. */
    static final class Section {
        String project, file, sha;
        final List<Hunk> hunks = new ArrayList<>();
        final List<String[]> sets = new ArrayList<>();   // {key, value} pairs for "set:"
    }

    public static void main(String[] args) throws Exception {
        if (args.length == 0) usage();
        switch (args[0]) {
            case "apply":    need(args, 3); applyAll(Paths.get(args[1]), Paths.get(args[2])); break;
            case "sha256":   need(args, 2); System.out.println(sha256(readNormalised(Paths.get(args[1])))); break;
            case "extract":  need(args, 4); extract(Paths.get(args[1]), args[2], Paths.get(args[3])); break;
            case "copytree": need(args, 3); copyTree(Paths.get(args[1]), Paths.get(args[2])); break;
            default: usage();
        }
    }

    static void need(String[] a, int n) { if (a.length != n) usage(); }

    static void usage() {
        System.err.println("usage: java MortPatch.java apply <patches-dir> <work-dir>\n"
                + "       java MortPatch.java sha256 <file>\n"
                + "       java MortPatch.java extract <zip> <entry> <dest>\n"
                + "       java MortPatch.java copytree <src> <dest>");
        System.exit(2);
    }

    // ---- apply ---------------------------------------------------------------

    static void applyAll(Path patchDir, Path workDir) throws Exception {
        // Collect *.mpatch files and sort them, so 01-, 02-, ... run in order.
        List<Path> patches = new ArrayList<>();
        try (DirectoryStream<Path> ds = Files.newDirectoryStream(patchDir, "*.mpatch")) {
            for (Path p : ds) patches.add(p);
        }
        Collections.sort(patches);
        if (patches.isEmpty()) die("no .mpatch files in " + patchDir);

        for (Path p : patches) {
            System.out.println("[patch] " + p.getFileName());
            for (Section s : parse(p)) applySection(s, workDir, p);
        }
    }

    /** Read a .mpatch file into sections. Very small, strict parser. */
    static List<Section> parse(Path p) throws IOException {
        List<Section> out = new ArrayList<>();
        Section cur = null;
        Hunk hunk = null;
        String project = null;
        int n = 0;
        for (String line : readNormalised(p).split("\n", -1)) {
            n++;
            if (line.startsWith("+")) {                      // body line of the current hunk
                if (hunk == null) die(p + ":" + n + ": '+' line outside a hunk");
                hunk.body.add(line.substring(1));
                continue;
            }
            hunk = null;                                     // any other line ends the hunk body
            String t = line.trim();
            if (t.isEmpty() || t.startsWith("#")) continue;  // blank lines and comments
            if (t.startsWith("project:")) { project = t.substring(8).trim(); continue; }
            if (t.startsWith("file:")) {                     // start a new target file
                cur = new Section();
                cur.project = project;
                cur.file = t.substring(5).trim();
                out.add(cur);
                continue;
            }
            if (cur == null) die(p + ":" + n + ": instruction before 'file:'");
            if (t.startsWith("sha256:")) { cur.sha = t.substring(7).trim().toLowerCase(Locale.ROOT); continue; }
            if (t.startsWith("set:")) {                      // "set: key value"
                String[] kv = t.substring(4).trim().split("\\s+", 2);
                cur.sets.add(new String[]{kv[0], kv.length > 1 ? kv[1] : ""});
                continue;
            }
            hunk = new Hunk();
            hunk.sourceLine = n;
            if (t.startsWith("replace ")) {                  // "replace A-B" or "replace A"
                String[] r = t.substring(8).trim().split("-");
                hunk.from = Integer.parseInt(r[0]);
                hunk.to = Integer.parseInt(r.length > 1 ? r[1] : r[0]);
            } else if (t.startsWith("insert-after ")) {      // "insert-after N"
                int a = Integer.parseInt(t.substring(13).trim());
                hunk.from = a + 1;
                hunk.to = a;                                 // empty range = pure insertion
            } else {
                die(p + ":" + n + ": unknown instruction: " + t);
            }
            cur.hunks.add(hunk);
        }
        return out;
    }

    static void applySection(Section s, Path workDir, Path patchFile) throws Exception {
        if (s.project == null) die(patchFile + ": missing 'project:'");
        Path target = workDir.resolve(s.project).resolve(s.file);
        if (!Files.isRegularFile(target)) die("missing file " + target + " (wrong APK or apktool version?)");
        String text = readNormalised(target);

        // 1) Safety first: the file must be exactly the one these line numbers were made for.
        if (s.sha != null) {
            String actual = sha256(text);
            if (!actual.equals(s.sha))
                die(s.file + ": checksum mismatch\n  expected " + s.sha + "\n  found    " + actual
                        + "\n  Use the original MortPlayer 1.0.1 APK and apktool 2.4.0, and apply each patch only once.");
        }

        // Split into lines. A decoded file normally ends with '\n', giving one empty last element we keep aside.
        boolean endsWithNewline = text.endsWith("\n");
        List<String> lines = new ArrayList<>(Arrays.asList(
                (endsWithNewline ? text.substring(0, text.length() - 1) : text).split("\n", -1)));

        // 2) Line-number hunks, applied from the bottom up so earlier numbers stay valid.
        List<Hunk> hunks = new ArrayList<>(s.hunks);
        hunks.sort((a, b) -> Integer.compare(b.from, a.from));
        int lastFrom = Integer.MAX_VALUE;
        for (Hunk h : hunks) {
            if (h.from < 1 || h.to > lines.size() || h.to < h.from - 1 || h.to >= lastFrom)
                die(patchFile + ":" + h.sourceLine + ": bad or overlapping line range");
            for (int i = h.to; i >= h.from; i--) lines.remove(i - 1);   // drop the old lines
            lines.addAll(h.from - 1, h.body);                           // put ours in
            lastFrom = h.from;
        }

        // 3) "set:" lines for apktool.yml (its first line contains the APK file name, so no checksum there).
        for (String[] kv : s.sets) {
            int hits = 0;
            for (int i = 0; i < lines.size(); i++) {
                String l = lines.get(i);
                String trimmed = l.trim();
                if (trimmed.startsWith(kv[0] + ":")) {
                    String indent = l.substring(0, l.indexOf(trimmed));
                    lines.set(i, indent + kv[0] + ": " + kv[1]);
                    hits++;
                }
            }
            if (hits != 1) die(s.file + ": expected exactly one '" + kv[0] + ":' line, found " + hits);
        }

        String result = String.join("\n", lines) + (endsWithNewline ? "\n" : "");
        Files.write(target, result.getBytes(StandardCharsets.UTF_8));
        System.out.println("        " + s.file + " (" + s.hunks.size() + " hunk(s)"
                + (s.sets.isEmpty() ? "" : ", " + s.sets.size() + " setting(s)") + ")");
    }

    // ---- helpers ---------------------------------------------------------------

    /** Read a text file as UTF-8 with Windows line endings turned into '\n' so checksums match everywhere. */
    static String readNormalised(Path p) throws IOException {
        return new String(Files.readAllBytes(p), StandardCharsets.UTF_8).replace("\r\n", "\n");
    }

    static String sha256(String s) throws Exception {
        byte[] d = MessageDigest.getInstance("SHA-256").digest(s.getBytes(StandardCharsets.UTF_8));
        StringBuilder sb = new StringBuilder();
        for (byte b : d) sb.append(String.format("%02x", b));
        return sb.toString();
    }

    static void extract(Path zip, String entry, Path dest) throws IOException {
        try (ZipFile z = new ZipFile(zip.toFile())) {
            ZipEntry e = z.getEntry(entry);
            if (e == null) die(entry + " not found in " + zip);
            try (InputStream in = z.getInputStream(e)) {
                Files.copy(in, dest, StandardCopyOption.REPLACE_EXISTING);
            }
        }
    }

    static void copyTree(Path src, Path dest) throws IOException {
        Files.walk(src).forEach(p -> {
            try {
                Path t = dest.resolve(src.relativize(p).toString());
                if (Files.isDirectory(p)) Files.createDirectories(t);
                else {
                    if (Files.exists(t)) die("refusing to overwrite existing file " + t);
                    Files.copy(p, t);
                    System.out.println("[new]   " + src.relativize(p));
                }
            } catch (IOException e) { throw new UncheckedIOException(e); }
        });
    }

    static void die(String msg) {
        System.err.println("ERROR: " + msg);
        System.exit(1);
    }
}
