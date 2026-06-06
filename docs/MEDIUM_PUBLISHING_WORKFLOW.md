# Medium.com Publishing Workflow

> Learned the hard way on 2026-02-22. This is the definitive playbook for publishing articles to Medium via Playwright browser automation.

## Key Constraints

- **Medium has NO usable API for posting** — must use the browser editor
- **Medium does NOT accept raw markdown** — pasting markdown shows literal syntax
- **Medium clipboard paste loses some `<h2>` headings** — they merge with preceding paragraph text
- **SVGs don't work on Medium** — convert to PNG first (`rsvg-convert -w 1600 -h 900`)
- **Playwright MCP restricted roots** — images must be within allowed directories
- **Medium's `End` key goes to visual line end**, not paragraph end — pressing Enter mid-paragraph splits it
- **Medium auto-saves** but "Save and publish" must be clicked to update the live article

## Step-by-Step Workflow

### Phase 1: Prepare Content

1. **Write the article as Markdown** with all formatting (headings, code blocks, bold, italic, links, blockquotes, lists)
2. **Convert Markdown → HTML** for clipboard paste:
   - Use proper semantic HTML: `<h2>`, `<h3>`, `<p>`, `<pre><code>`, `<blockquote>`, `<ol>`, `<ul>`, `<strong>`, `<em>`, `<code>`, `<a href="...">`
   - Each section should be wrapped in proper tags
   - Do NOT rely on `<h2>` rendering — Medium often drops them from clipboard. Use `<h3>` as a safer bet for subheadings (Medium renders H3 as its section heading style)
3. **Convert all SVG images to PNG**:
   ```bash
   rsvg-convert -w 1600 -h 900 input.svg -o output.png
   ```
4. **Copy all images to a Playwright-accessible directory** (within the allowed roots)

### Phase 2: Create the Article

1. **Navigate to** `https://medium.com/new-story`
2. **Set the title** — click the title area and type
3. **Paste content as rich HTML** using Playwright's `browser_run_code`:
   ```javascript
   async (page) => {
     // Focus the editor
     const editor = page.locator('[role="textbox"]');
     await editor.click();
     
     // Paste HTML via clipboard API
     await page.evaluate((html) => {
       const clipboardData = new DataTransfer();
       clipboardData.setData('text/html', html);
       const event = new ClipboardEvent('paste', {
         bubbles: true,
         cancelable: true,
         clipboardData: clipboardData
       });
       document.activeElement.dispatchEvent(event);
     }, htmlContent);
   }
   ```
4. **Paste in chunks** if article is long (Medium may truncate large single pastes). Split at natural section boundaries (~3000 chars per chunk).

### Phase 3: Insert Images

**Pattern for each image:**

1. **Position cursor** — click on the paragraph/element NEAR where the image should go
2. **Create an empty line**:
   - For inserting BEFORE a paragraph: click paragraph → `Home` → `Enter` → `ArrowUp`
   - For inserting AFTER a list: click last list item → `End` → `Enter` → `Enter` (double Enter exits the list)
   - **WARNING**: `End` key goes to visual line end, not paragraph end. If paragraph wraps multiple lines, clicking the bottom-right of the paragraph's bounding box is more reliable.
3. **Click the `+` add button**: `[data-testid="editorAddButton"]`
4. **Click "Add an image"**: `getByRole('button', { name: 'Add an image', exact: true })`
5. **Handle file chooser**: `browser_file_upload` with the image path
6. **Wait for upload** — Medium sometimes triggers a SECOND file chooser. If the snapshot shows `[File chooser]` again, call `browser_file_upload` again.

### Phase 4: Publish

1. **Click "Publish"** or **"Save and publish"** button
2. **Set tags** in the publish dialog (Git, DevOps, etc.)
3. **Set canonical URL** (Settings → Story settings → Original story URL) if cross-posting
4. **Verify** the published article by taking a snapshot of the live page

## Common Pitfalls & Solutions

| Problem | Solution |
|---------|----------|
| H2 headings lost in paste | Use H3 instead, or manually fix in editor after paste |
| Paragraph splits on Enter | Use `Cmd+Z` (Meta+z) to undo, then use bounding box click approach |
| Image not in right position | Position cursor more carefully — use `scrollIntoViewIfNeeded()` + `boundingBox()` for precision |
| SVG images rejected | Convert to PNG with `rsvg-convert` |
| Footer text splits on edit | Avoid editing near section separators (the `---` rules) — Medium treats sections as separate containers |
| Medium section separators | Medium wraps content between `---` in separate `<generic>` containers. Content after a separator is in a different DOM section — plan image placement accordingly |
| File chooser appears twice | Call `browser_file_upload` again with the same file |

## Medium Editor DOM Structure

```
article
  └── textbox (main editor)
      ├── generic (title section)
      │   └── heading (title)
      ├── generic (section between separators)
      │   ├── blockquote (TL;DR)
      │   └── ...
      ├── generic (main content section)
      │   ├── figure (image) — created by image upload
      │   ├── heading (H2/H3)
      │   ├── paragraph
      │   ├── generic (code block)
      │   ├── list > listitem
      │   └── ...
      ├── generic (closing section — after separator)
      │   └── paragraph
      └── generic (footer section — after separator)
          └── paragraph (attribution/credits)
```

## Key Selectors

- **Add media button**: `[data-testid="editorAddButton"]`
- **Add image**: `getByRole('button', { name: 'Add an image', exact: true })`
- **Save and publish**: `getByRole('button', { name: 'Save and publish' })`
- **Editor textbox**: `[role="textbox"]`
- **File chooser**: Handled via `browser_file_upload` tool

## Image Placement Strategy

Place images in this order to avoid shifting content:
1. **Top to bottom** — start from the first image position and work down
2. **Before headings** — images look best as section openers
3. **After code blocks / lists** — as visual breaks
4. **Avoid placing near section separators** — the DOM structure is tricky there

## Cleanup

After publishing, remove temp image files:
```bash
rm -rf /path/to/temp-medium-images/
```
