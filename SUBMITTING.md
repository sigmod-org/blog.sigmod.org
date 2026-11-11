# Publishing and updating posts on the ACM SIGMOD Blog

This guide covers the whole path from a pitch to a published post, and how to update
what is already online. It is written so that a person **or an AI agent** can follow
it step by step: every step says exactly what to type and what you should see.

The blog is a [Jekyll](https://jekyllrb.com/) site in the GitHub repository
[sigmod-org/blog.sigmod.org](https://github.com/sigmod-org/blog.sigmod.org).
Every change goes through a **pull request** (PR). When a PR is merged into `main`, GitHub
builds the site and publishes it at <https://blog.sigmod.org> within a few minutes.

**Contents**

1. [Who does what](#1-who-does-what)
2. [Pitch and write (authors)](#2-pitch-and-write-authors)
3. [One-time setup](#3-one-time-setup)
4. [Find or add the authors](#4-find-or-add-the-authors)
5. [Create the post](#5-create-the-post)
6. [Preview locally](#6-preview-locally)
7. [Open the pull request](#7-open-the-pull-request)
8. [Review: preview a pull request on your own computer](#8-review-preview-a-pull-request-on-your-own-computer)
9. [Merge and publish](#9-merge-and-publish)
10. [Updating what is already online](#10-updating-what-is-already-online)
11. [Checklist](#11-checklist)
12. [Instructions for AI agents](#12-instructions-for-ai-agents)
13. [Troubleshooting](#13-troubleshooting)
14. [Reference: front matter fields](#14-reference-front-matter-fields)

---

## 1. Who does what

| Who | Does | Needs |
|---|---|---|
| **Author** | Pitches, writes, sends the files ([section 2](#2-pitch-and-write-authors)); reviews the PR and approves it ([section 8](#8-review-preview-a-pull-request-on-your-own-computer)). | Email. A GitHub account to comment on the PR; Ruby only to preview it locally. |
| **Editor** | Creates the post and opens the PR (sections 4–7), reviews, merges (section 9). | GitHub account with write access to the repository, git, Ruby. |
| **AI agent** (optional) | Can do sections 4–7 for an editor, and open the PR. Never merges. | See [section 12](#12-instructions-for-ai-agents). |

Authors who are comfortable with GitHub may also open the PR themselves
(from a fork, see [section 7](#7-open-the-pull-request)).

The flow:

```
pitch → draft (author) → post files on a branch → local preview → pull request
      → review by author + other editor (each may preview the PR locally)
      → author approves → editor merges → live on blog.sigmod.org
```

---

## 2. Pitch and write (authors)

1. **Pitch first.** Email the editors (see the [Editors page](https://blog.sigmod.org/editors/))
   a short pitch: two or three sentences on the idea and why it matters now.
2. **Write.** Posts usually run between 1,000 and 3,000 words; 2,000 is a good
   target. Write for the broad data management community, not only specialists.
3. **Send the editors:**
   - the text (Google Doc, Word, or Markdown are all fine);
   - figures as separate image files (PNG or JPG, at least 1200 px wide), with captions;
   - for **each** author: the name as it should appear, a homepage URL, a short bio
     (2–4 sentences) and a headshot (square-ish, at least 300 × 300 px);
   - for a co-written post, the **order** of the authors in the byline;
   - 1–3 suggested categories (see the list in [section 5.4](#54-categories)).

The editors take it from there. Authors will be asked to review the post as it will
appear online before it is published ([section 8](#8-review-preview-a-pull-request-on-your-own-computer)).

---

## 3. One-time setup

You need **git**, the **GitHub CLI** (`gh`, optional but used in this guide), and
**Ruby 3.2 or newer** with **Bundler** (the live site is built with Ruby 4.0).

### 3.1 Install the tools

**macOS** (with [Homebrew](https://brew.sh/)):

```bash
brew install git gh ruby
```

Homebrew's Ruby is not on your `PATH` by default. Add it (Apple Silicon Macs;
on Intel Macs use `/usr/local/opt/ruby/bin`), then open a new terminal:

```bash
echo 'export PATH="/opt/homebrew/opt/ruby/bin:$PATH"' >> ~/.zshrc
```

**Ubuntu / Debian:**

```bash
sudo apt install git gh ruby-full build-essential zlib1g-dev
```

**Windows:** install [WSL](https://learn.microsoft.com/windows/wsl/install) (Ubuntu)
and follow the Ubuntu steps inside it.

Then, on every system:

```bash
gem install bundler
gh auth login
```

Check: `ruby -v` prints 3.2 or newer, and `gh auth status` says you are logged in.

### 3.2 Get the repository

**Editors** (with write access):

```bash
git clone https://github.com/sigmod-org/blog.sigmod.org.git
cd blog.sigmod.org
```

**Authors and others** (no write access) work on their own copy, a *fork*:

```bash
gh repo fork sigmod-org/blog.sigmod.org --clone
cd blog.sigmod.org
```

### 3.3 Install the site's dependencies and build it once

```bash
bundle install
bundle exec jekyll serve
```

Open <http://localhost:4000/>: you should see the blog. Stop the server with
**Ctrl+C**. You only need `bundle install` again when `Gemfile.lock` changes.

### 3.4 Before every new piece of work

Start from the latest `main`:

```bash
git switch main
git pull
```

(In a fork, also run `gh repo sync` first, so your fork has the latest posts.)

---

## 4. Find or add the authors

Every author is a **person** with one entry in `_data/authors.yml`, identified by a
**key** (for example `julia-stoyanovich`). The key is what posts use; the author's
page is `https://blog.sigmod.org/author/<key>/`.

### 4.1 Search for an existing author first

Many people have written for the blog before. **Always search before adding**, so a
person never ends up with two entries (and two author pages).

```bash
ruby tools/find_author.rb stoyanovich
```

```
julia-stoyanovich  Julia Stoyanovich  (photo)
```

- Search by **surname**; case and accents do not matter (`ozsu` finds *M. Tamer Özsu*).
- Each line shows the **key** to use, the name, and whether a headshot is set.
- `ruby tools/find_author.rb` with no argument lists everyone.
- No match prints `No author matches …`: try another spelling (e.g. only part of the surname)
  before concluding the person is new.

You can also browse <https://blog.sigmod.org/authors/>; an author page's address
ends in the key (`/author/julia-stoyanovich/`).

**Old keys look odd, use them anyway.** Authors imported from the old WordPress blog
keep their old keys (e.g. `abouziedazza` for Azza Abouzied, `sihem` for Sihem Amer-Yahia,
`tamer` for M. Tamer Özsu). Reuse the existing key; do not create a "nicer" duplicate.

**Never use a combined entry.** `_data/authors.yml` also contains entries for old
group bylines, such as `azzaandpaolo`, with a `members:` list. They exist only so old
posts and links keep working. `find_author.rb` hides them; new posts always list the
individual people.

### 4.2 Add a new author

Only if the search found nobody. Add one entry **per person** to `_data/authors.yml`:

```yaml
"jane-doe":
  name: "Jane Doe"
  url: "https://janedoe.example.org"
  avatar: "/assets/authors/jane-doe.jpg"
```

- **Key:** `firstname-lastname`, lowercase ASCII, hyphens, no accents
  (`zi-helen-huang`, `m-tamer-ozsu`). It becomes part of a URL, so it never changes later.
- **name:** exactly as it should appear in the byline, accents included.
- **url** (optional): the author's homepage.
- **avatar** (optional): the headshot. Without one, the blog shows the first letter of the name.
- Keep the quotes; the order of entries in the file does not matter.

That is all: the page `/author/jane-doe/` is created automatically (by `_plugins/authors.rb`).
Do **not** create a file in `author/`; those are only for authors from the old blog.

### 4.3 Add the headshot

Save it as `assets/authors/<key>.jpg`: a **square** JPEG, **300 × 300 px**, face
centred with a little space above the head. The blog shows it as a circle, so leave a
margin: anything in the corners is cut off.

To make one on macOS from any photo (crop it to a square first, e.g. in Preview):

```bash
sips -s format jpeg -z 300 300 headshot.png --out assets/authors/jane-doe.jpg
```

Check it in the preview (section 6): the face should be fully inside the circle,
including the top of the head and the chin.

### 4.4 Co-written posts

Add (or find) each author separately, then list their keys in the post **in byline
order** (section 5.2). The byline then reads "by Jane Doe and John Roe" (or
"by A, B, and C"), each name links to that person's page, and the post appears on
each author's page.

---

## 5. Create the post

### 5.1 Make a branch

One branch per post, named after the post file:

```bash
git switch -c post/2026-11-15-learned-indexes-revisited
```

### 5.2 Create the post file

Create `_posts/YYYY-MM-DD-short-title.md`:

- **YYYY-MM-DD** is the **publication date** (not today's date, unless it is published today).
- **short-title** is lowercase words joined by hyphens, ASCII only. It becomes the URL:
  `_posts/2026-11-15-learned-indexes-revisited.md` → `https://blog.sigmod.org/2026/11/15/learned-indexes-revisited/`.

Template:

```markdown
---
title: "Learned Indexes, Revisited"
authors: [jane-doe, john-roe]
categories: [Databases, Machine Learning]
excerpt: "One or two sentences that appear under the title on the home page."
image: /assets/posts/2026-11-15-learned-indexes-revisited/figure1.png
---

Opening paragraph, in Markdown: **bold**, *italics*, [links](https://sigmod.org),
tables, footnotes.[^1]

## A section heading

![Figure 1: Caption.]({{ '/assets/posts/2026-11-15-learned-indexes-revisited/figure1.png' | relative_url }})

*Figure 1: Caption.*

## About the authors

**Jane Doe** is …

**John Roe** is …

[^1]: Footnote text.
```

Rules for the part between the `---` lines (the *front matter*; all fields are listed in
[section 14](#14-reference-front-matter-fields)):

- **title:** always in double quotes. A title with a colon and no quotes breaks the
  build of this post. A double quote inside the title is written `\"`.
- **authors:** keys from section 4, in byline order. For one author, either
  `authors: [jane-doe]` or `author: jane-doe`.
- **categories:** existing category names, spelled exactly as listed (section 5.4).
- **excerpt** (optional): otherwise the first paragraph is used.
- **image** (optional): a thumbnail shown next to the post on the home page.

For the body:

- Use `##` for section headings (the title is the only top-level heading).
- HTML also works where Markdown is not enough, e.g. `<figure>` with `<figcaption>`.
- **Convert, do not rewrite.** From Google Docs: *File → Download → Markdown (.md)*.
  From Word: `pandoc draft.docx -t gfm -o post.md`. Then tidy the result: front matter,
  headings, image paths, footnotes. Do not change the author's wording.
- Put the authors' bios at the end, under *About the author(s)*.

### 5.3 Add the images

Put a post's images in a folder named exactly like the post file (without `.md`):

```
assets/posts/2026-11-15-learned-indexes-revisited/figure1.png
```

- At most ~1600 px wide and under ~1 MB each. On macOS:
  `sips -Z 1600 figure1.png` (shrinks in place, keeps the proportions).
- Always link them with `relative_url`, as in the template:
  `{{ '/assets/posts/<post-file-name>/<image>' | relative_url }}`.
- Every figure needs a caption, and the image itself should have alt text
  (the part in `![…]`).

### 5.4 Categories

List the existing ones:

```bash
grep -h '^title:' category/*.html | sed 's/title: //; s/"//g' | sort -f
```

Use the names exactly as printed (capitals and spaces matter). Prefer existing
categories. To add a new one, create `category/<slug>.html`, where the slug is the
name in lowercase with hyphens:

```yaml
---
layout: category
title: "Vector Databases"
category: "Vector Databases"
permalink: /category/vector-databases/
---
```

`category:` must match the name used in the posts exactly.

---

## 6. Preview locally

```bash
bundle exec jekyll serve --future
```

- `--future` is needed for a post dated after today; without it, the post is **not
  built** and seems to be missing.
- Open the post at `http://localhost:4000/YYYY/MM/DD/short-title/`.
- The server rebuilds when you save a file; reload the page to see the change.
  (Changes to `_config.yml` need a restart: Ctrl+C, then the command again.)

**Read the terminal output.** A clean build prints no red or yellow lines. Two
messages to watch for:

| Message | Meaning | Fix |
|---|---|---|
| `Authors: no _data/authors.yml entry for "jane-doe"` (yellow) | An author key in the post does not exist (typo, or the entry was not added). | Correct the key, or add the author (section 4.2). |
| `YAML Exception reading …/_posts/….md` (red) | The front matter is invalid; the post is skipped. | Usually an unquoted title with a colon, or a missing `---`. |

**Check on the page:**

- [ ] title, date, and the byline: every author, in the right order, each name a link;
- [ ] the categories under the title, and each one opens a category page;
- [ ] every figure loads, with its caption; tables and footnotes look right;
- [ ] the links work (click a few);
- [ ] at the end, *Posted by* shows each author with their photo, and the bios are there;
- [ ] each author's page (`/author/<key>/`) lists the post;
- [ ] the home page (<http://localhost:4000/>) shows the post with its excerpt (and thumbnail, if any);
- [ ] it reads well on a phone: narrow the browser window to ~375 px.

---

## 7. Open the pull request

### 7.1 From the command line (recommended)

```bash
git add _posts/2026-11-15-learned-indexes-revisited.md \
        assets/posts/2026-11-15-learned-indexes-revisited \
        _data/authors.yml assets/authors
git status
git commit -m "New post: Learned Indexes, Revisited (Jane Doe, John Roe)"
git push -u origin HEAD
gh pr create --repo sigmod-org/blog.sigmod.org \
  --title "New post: Learned Indexes, Revisited" \
  --body "Post by Jane Doe and John Roe, to be published on 2026-11-15.

- [ ] Author approved the final version
- [ ] Reviewed by a second editor"
```

- `git status` before committing: only the files of this post (and any new author
  or category) should be listed.
- From a fork, `gh pr create` opens the PR against `sigmod-org/blog.sigmod.org` all
  the same. Leave *Allow edits by maintainers* on, so editors can fix small things.
- `gh pr create` prints the PR's address: send it to the author and the other editor.

### 7.2 From the GitHub website (no git needed)

1. Open the repository, switch to `main`, and go into the `_posts` folder.
2. *Add file → Create new file*, name it `2026-11-15-learned-indexes-revisited.md`,
   paste the post, and choose *Create a new branch for this commit and start a pull
   request* (without write access, GitHub makes a fork for you automatically).
3. On **that branch**, go to `assets/posts/` and use *Add file → Upload files*: drag in the
   whole folder `2026-11-15-learned-indexes-revisited` with the images. Do the same for
   a headshot in `assets/authors/`, and edit `_data/authors.yml` with the pencil icon.
   Always commit to the same branch.
4. Open the pull request from the banner GitHub shows.

### 7.3 Updating the PR after review

Make the changes on the same branch, then:

```bash
git add -A
git commit -m "Address review comments"
git push
```

The PR updates itself; there is no need to open a new one.

---

## 8. Review: preview a pull request on your own computer

GitHub shows the changed files of a PR, but not the rendered post. To see the post
exactly as it will look online, reviewers (the author, the other editor) build the PR
locally. You need the one-time setup from [section 3](#3-one-time-setup) (tools and a
clone; a fork is not needed just to review).

1. Find the PR number: it is in the address, e.g. `…/pull/42` → **42**.
2. In your clone:

   ```bash
   cd blog.sigmod.org
   git switch main && git pull
   gh pr checkout 42
   bundle install
   bundle exec jekyll serve --future
   ```

   Without `gh`: `git fetch origin pull/42/head:pr-42 && git switch pr-42` instead of
   `gh pr checkout 42`.
3. Open the post at `http://localhost:4000/YYYY/MM/DD/short-title/` (the date and
   short title are in the PR's file name) and go through the checks in
   [section 6](#6-preview-locally).
4. **Comment on the PR** on GitHub:
   - for a small fix, open *Files changed*, click the line, and use *Add a suggestion*,
     so the editor can apply it with one click;
   - otherwise write what should change.
5. When the PR is updated, get the new version and reload the page:

   ```bash
   gh pr checkout 42
   ```

   (or `git pull` while on the PR's branch). The running server picks the change up.
6. **The author approves** by writing a comment such as *"Approved for publication"*
   on the PR. The other editor approves with *Review changes → Approve*.
7. Afterwards, go back to `main`: `git switch main`.

**Cannot install Ruby?** Open the PR on GitHub, then *Code → Codespaces → Create
codespace*, and run `bundle install` and `bundle exec jekyll serve --future` in its
terminal; Codespaces offers to open port 4000 in the browser. (This has not yet been
tried with this repository; if it fails, ask the editors for screenshots instead.)

---

## 9. Merge and publish

1. Check that the PR has the **author's approval** and a **second editor's review**,
   and that the checklist ([section 11](#11-checklist)) is complete.
2. Merge with *Squash and merge* (one commit per post on `main`).
3. Within a few minutes the post is at `https://blog.sigmod.org/YYYY/MM/DD/short-title/`.
   Follow the build in the repository's *Actions* tab: a green ✓ means it is live, a
   red ✗ means the build failed and the site still shows the previous version
   (open the run to see the error; usually a front-matter typo).
4. Delete the branch (the button on the merged PR).

**A post dated in the future** is only published by a build on or after that date.
Merge it on the publication day, or merge earlier and then, on the day, re-run the
latest workflow from *Actions → Deploy to GitHub Pages → Run workflow*.

---

## 10. Updating what is already online

All updates go through a PR, exactly like a new post (branch, preview, PR, review, merge).

| Change | How |
|---|---|
| **Fix a typo or a link in a post** | Edit the post file. If its front matter has a `wp_id:` line (imported from the old blog), also add `keep_local_edits: true`, so a later re-import does not overwrite your fix. |
| **Change an author's name, homepage or photo** | Edit their entry in `_data/authors.yml`, or replace `assets/authors/<key>.jpg`. It changes everywhere the author appears. Never change the **key**. |
| **Add a missing co-author to a post** | Add the person (section 4), then list everyone in the post's `authors:` (replacing `author:`). For an old post whose `author:` is a combined entry (one with `members:`), add the person to that entry's `members` list instead. |
| **Add or fix a category** | See section 5.4. Renaming a category changes its URL; avoid it. |
| **Replace an image** | Overwrite the file with the same name, or add a new file and update the link. |
| **Remove a post** | An editorial decision. Deleting the file makes its URL return "page not found". |

**Never rename a published post's file** and never change its date: both change the
URL, and links to it from elsewhere break.

---

## 11. Checklist

Before asking for review, and again before merging:

- [ ] File name: publication date and a short, lowercase, hyphenated title.
- [ ] `title` in double quotes; front matter builds without red or yellow messages.
- [ ] Every author found with `tools/find_author.rb` or added once, in byline order; no combined entries.
- [ ] Each new author has a name, and ideally a homepage and a 300 × 300 headshot that fits the circle.
- [ ] Categories exist and are spelled exactly.
- [ ] Images in `assets/posts/<post-file-name>/`, under ~1 MB, linked with `relative_url`, with captions and alt text.
- [ ] Links work; bios at the end.
- [ ] Previewed locally with `--future`, including on a narrow window.
- [ ] Wording unchanged from the author's approved version.
- [ ] **The author approved the final version on the PR**; a second editor reviewed it.

---

## 12. Instructions for AI agents

An AI coding agent (for example [Claude Code](https://www.anthropic.com/claude-code))
can do sections 4–7 for an editor. Claude Code also reads [CLAUDE.md](CLAUDE.md)
automatically when it works in this repository. That file sets the order of work: check
the authors first and ask when unsure, then prepare the post. Other agents should be
pointed to it.

Give the agent three things: **the post** (a Google Drive or Docs link, or the text
itself), **the authors' names** in byline order, and **a photo for each author**. Add
the publication date and the categories. For example:

> Prepare this post for the SIGMOD Blog: https://docs.google.com/document/d/…
> Authors: Jane Doe (photo: https://…/jane.jpg), John Roe (photo attached).
> Publish on 2026-11-15, categories "Databases" and "Machine Learning".

The agent first checks each author against the existing ones and asks you to confirm
anything uncertain. Only then does it prepare the post, show you the preview, and open
the pull request. It never merges.

**Rules for the agent** (follow all of them):

1. **Do not edit the text.** Convert formatting only; keep every sentence as the author
   wrote it. If something looks wrong (a typo, a broken reference), list it for the
   editor instead of changing it.
2. **Check the authors first, and ask when unsure.** Before converting anything, run
   `ruby tools/find_author.rb <surname>` for every author. Reuse an exact match even if
   its key looks odd. If there are several matches, a similar but different name, or a
   different affiliation, ask the editor; do not guess. Add an entry only when the
   surname alone finds nothing. If an existing author already has a photo, ask before
   replacing it. Never use or create a combined entry (one with `members:`) for a new
   post. CLAUDE.md shows how to ask.
3. **Use the publication date** the editor gave, not today's date, in the file name.
4. **Work on a new branch** named `post/<post-file-name>`, created from an up-to-date
   `main`. Never commit to `main` directly.
5. **Commit only this post's files**: the post, its image folder, and new entries or
   headshots for its authors (and a new category file, if asked for one).
6. **Build and check.** Run `bundle exec jekyll serve --future` (or
   `bundle exec jekyll build --future`) and confirm the output has no
   `Authors: no _data/authors.yml entry` warning and no `YAML Exception`. If you can
   open a browser, go through every check in [section 6](#6-preview-locally) on the
   post page, the author pages and the home page.
7. **Headshots:** crop to a square with the whole face inside the central circle
   (top of the head and chin visible), resize to 300 × 300, save as
   `assets/authors/<key>.jpg`, and look at the result before committing.
8. **Open the PR, never merge.** Use the title `New post: <title>` and a body with the
   publication date, the authors, and the checklist from section 11. Report back:
   the PR link, the local preview URL, every new author key and category you added,
   and anything you were unsure about.
9. **Do not publish drafts elsewhere.** Unpublished manuscripts stay in this repository
   and the tools the editors approved; do not upload them to other services.

Watch for the mistakes agents make most often: a wrong date, a duplicate author
entry, a category that almost matches an existing one, an unquoted title with a colon,
and image paths without `relative_url`.

Agents can also help **authors** with section 2, for example converting a draft to
Markdown or checking references, as long as the text remains their own.

---

## 13. Troubleshooting

| Problem | Cause and fix |
|---|---|
| The post does not appear locally | Its date is in the future: add `--future`. Or its front matter is invalid: look for a red `YAML Exception` line. |
| `bundle: command not found`, or Ruby is too old | On macOS the system Ruby is being used: add Homebrew's Ruby to your `PATH` (section 3.1) and open a new terminal; then `gem install bundler`. |
| `bundle install` fails while building a gem | Install the compiler tools: `xcode-select --install` (macOS) or `sudo apt install build-essential` (Ubuntu). |
| `Address already in use` on port 4000 | Another preview is still running. Stop it (Ctrl+C in its terminal) or use `bundle exec jekyll serve --future --port 4001`. |
| An image does not load | The path is wrong (folder name must equal the post file name), the extension's case differs (`.PNG` vs `.png`), or `relative_url` is missing. |
| A name in the byline shows a key such as `jane-doe` | The key is missing from `_data/authors.yml`; the build prints a yellow `Authors:` warning. |
| A category link shows "page not found" | The category name does not match any file in `category/`: fix the spelling or add the category (section 5.4). |
| The live site did not change after a merge | Check the *Actions* tab: the build may still be running, or it failed (red ✗). |
| A post shows "0 reads" or no reads count | Normal for a new post: views are counted on the live site only, and the count appears after the first visit. |

---

## 14. Reference: front matter fields

| Field | Required | Example | Notes |
|---|---|---|---|
| `title` | yes | `"Learned Indexes, Revisited"` | Always in double quotes. |
| `authors` | yes (or `author`) | `[jane-doe, john-roe]` | Keys from `_data/authors.yml`, in byline order. |
| `author` | — | `jane-doe` | Single-author alternative to `authors`. |
| `categories` | yes | `[Databases, Machine Learning]` | Existing names, exact spelling. |
| `excerpt` | no | `"One or two sentences."` | Shown on the home page; default is the first paragraph. |
| `image` | no | `/assets/posts/<post-file-name>/figure1.png` | Thumbnail on the home page. |
| `date` | no | `2026-11-15 09:00:00` | Only to set a time of day; the date must match the file name. |
| `keep_local_edits` | old posts only | `true` | On posts imported from the old blog (they have `wp_id`), protects hand edits from re-imports. |

Fields such as `wp_id` and `last_modified_at` appear in imported posts; leave them as they are.
