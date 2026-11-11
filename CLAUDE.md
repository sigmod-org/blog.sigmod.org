# Instructions for Claude

This repository is the SIGMOD Blog (Jekyll, published at https://blog.sigmod.org).
The full publishing process is in [SUBMITTING.md](SUBMITTING.md); read it before
preparing a post. This file sets the order of work and the points where you must
stop and ask.

## Preparing a new post

### Step 0. Expect these inputs

The editor will give you:

1. **The post:** a link (usually Google Drive or Google Docs) or the text pasted
   into the chat, sometimes with image files.
2. **The authors:** a list of names, in byline order.
3. **A photo for each author:** a link or a file. Some may be missing.

Usually also a publication date and categories. If any of these is missing, ask for
it before you start, in one message. Do not guess the date: it decides the file name
and the URL.

If you cannot open the link (for example it needs a Google sign-in), say so. Ask the
editor to share the file publicly, or to paste or export it (*File → Download →
Markdown* or *.docx*). Do not try to log in.

### Step 1. Check every author first, before anything else

Do this before you convert the text or create any file. For each name:

```bash
ruby tools/find_author.rb <surname>
```

Then sort each author into one of three cases:

| Case | What you see | What to do |
|------|--------------|------------|
| **Exists** | Exactly one line, and the name matches the given name exactly (accents aside) | Reuse that key, even if it looks odd (`tamer`, `sihem`, `abouziedazza`) |
| **Unsure** | Several matches; a similar but different name (initials, middle name, different first name, a maiden or married name); or a match whose page shows a different affiliation | **Stop and ask** |
| **New** | `No author matches …` for the full surname, part of the surname, and the first name | Add a new entry (SUBMITTING.md §4.2) |

**When you are not sure, ask. Do not guess.** A wrong match puts a post on another
person's page. A wrong "new" creates a duplicate author. Both are hard to undo once
published.

Ask all the author questions together in one message, in this form:

> Before I prepare the post, please confirm the authors:
> 1. **Julia Stoyanovich** → existing `julia-stoyanovich` (has a photo). ✔
> 2. **J. Smith** → could be `john-smith` (John Smith) or `jane-smith` (Jane Smith). Which one, or someone new?
> 3. **Wei Li** → no existing entry. I will add `wei-li` with the photo you gave.

Wait for the answer before you continue.

**Photos for existing authors.** If an existing author already has a photo and the
editor sent a new one, ask whether to replace it. If the author has no photo, add
the new one.

**Never** use or create a combined entry (one with a `members:` list) for a new post.
List the individual people in `authors: [a, b, c]`.

### Step 2. Prepare the post

Follow SUBMITTING.md §5 to §7 and the agent rules in §12. In short:

- Branch `post/<post-file-name>` from an up-to-date `main`.
- Convert the formatting only. Never change the authors' wording; list any problems
  you notice for the editor instead.
- Headshots: 300 × 300 JPEG at `assets/authors/<key>.jpg`, with the whole face
  inside the circle. Look at each one before committing.
- Build with `bundle exec jekyll build --future`. There must be no `Authors: no
  _data/authors.yml entry` warning and no `YAML Exception`.
- Show the editor the local preview. Push the branch and open the PR once they
  agree. **Never merge, and never push to `main`.**

### Step 3. Report back

Give the PR link and the local preview URL. Then list every author key you reused or
added, every photo you added or replaced, any new category, and anything you were
unsure about.

## Other rules

- Outside the post workflow above, commit or push only when the editor says so.
- Unpublished drafts are confidential. Do not upload them to any service other than
  this repository.
- On macOS, use Homebrew's Ruby (`PATH=/opt/homebrew/opt/ruby/bin:$PATH`), not the system Ruby.
