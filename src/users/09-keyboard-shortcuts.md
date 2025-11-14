# Keyboard Shortcuts

Lemmy-UI supports keyboard shortcuts for navigation and interaction with posts and comments.

## Availability

Keyboard shortcuts work on pages that display posts or comments:
- Home page and community pages
- Individual post pages
- User profiles
- Search results
- Saved posts and comments
- Inbox and mentions
- Moderation queues

Shortcuts are automatically disabled when typing in input fields or forms.

## Navigation

### Post Lists

Navigate between posts on listing pages.

| Key | Action |
|-----|--------|
| **j** | Next post |
| **k** | Previous post |
| **J** | Last post |
| **K** | First post |

The currently selected post is highlighted. You can also click on a post to select it.

### Comments

Navigate through comments when viewing a post.

| Key | Action |
|-----|--------|
| **j** | Next comment (depth-first) |
| **k** | Previous comment |
| **J** | Next sibling (same level) |
| **K** | Previous sibling (same level) |
| **p** | Parent comment |
| **t** | Thread root (top-level comment) |

## Actions

Perform actions on the highlighted post or comment.

| Key | Action | Requires Login |
|-----|--------|----------------|
| **a** | Upvote (toggle) | Yes |
| **z** | Downvote (toggle) | Yes |
| **s** | Save/unsave (toggle) | Yes |
| **x** | Expand post | No |
| **e** | Edit | Yes (own content only) |
| **r** | Reply (comments) / Go to community (posts) | Context-dependent |
| **.** | Open actions menu | No |
| **Enter** | Collapse/expand comment | No |

**Notes:**
- Voting and save keys toggle - press again to undo
- The `r` key opens the community page when viewing posts, and replies to the comment when viewing comments
- The actions menu (`.`) provides access to additional options like report, block, and moderation actions

## Links

Open posts, comments, profiles, and communities. Lowercase keys open in the current tab, uppercase (Shift) opens in a new tab.

| Key | Action |
|-----|--------|
| **c** / **C** | Open comments |
| **l** / **L** | Open post link |
| **u** / **U** | Open user profile |
| **r** / **R** | Open community |

## Important Notes

- Shortcuts are disabled while typing in text inputs, textareas, or forms
- Browser extensions like Vimium may intercept keyboard shortcuts
- Browser-specific shortcuts always take priority
- On mobile, shortcuts only work with external keyboards
