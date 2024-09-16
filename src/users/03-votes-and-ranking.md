# Votes and Ranking

## Posts

Lemmy uses a voting system to sort post listings. On the left side of each post there are _up_ and _down_ arrows, which let you _upvote_ or _downvote_ it. You can upvote posts that you like so that more users will see them, or downvote posts so that they are less likely to be seen. Each post receives a score which is the number of upvotes minus the number of downvotes.

### Sorting Posts

When browsing the front page or a community, you can choose between the following sort types for posts:

- **Active** (default): Calculates a rank based on the score and time of the latest comment, with decay over time
- **Hot**: Like active, but uses time when the post was published
- **Scaled**: Like hot, but gives a boost to less active communities
- **New**: Shows most recent posts first
- **Old**: Shows oldest posts first
- **Most Comments**: Shows posts with highest number of comments first
- **New Comments**: Bumps posts to the top when they are created or receive a new reply, analogous to the sorting of traditional forums
- **Top Day**: Highest scoring posts during the last 24 hours
- **Top Week**: Highest scoring posts during the last 7 days
- **Top Month**: Highest scoring posts during the last 30 days
- **Top Year**: Highest scoring posts during the last 12 months
- **Top All Time**: Highest scoring posts of all time

## Comments

Comments are by default arranged in a hierarchy which shows at a glance who it is replying to. Top-level comments which reply directly to a post are on the very left, not indented at all. Comments that are responding to top-level comments are indented one level and each further level of indentation means that the comment is deeper in the conversation. With this layout, it is always easy to see the context for a given comment, by simply scrolling up to the next comment which is indented one level less.

### Sorting Comments

Comments can be sorted in the following ways. These all keep the indentation intact, so only replies to the same parent are shuffled around.

- **Hot** (default): Equivalent to the _Hot_ sort for posts
- **Top**: Shows comments with highest score first
- **New**: Shows most recent comments first
- **Old**: Shows oldest comments first

Additionally there is a sort option **Chat**. This eliminates the hierarchy, and puts all comments on the top level, with newest comments shown at the top. It is useful to see new replies at any point in the conversation, but makes it difficult to see the context.

The ranking algorithm is described in detail [here](../contributors/07-ranking-algo.md).

## Vote Privacy

Lemmy attempts to limit the visibility of votes to protect user privacy. But due to the way Lemmy works, votes cannot be completely private. Instance admins can see the names of everyone who voted on a given post or comment, and community moderators can see the names for the communities they moderate. This helps to fight against vote manipulation. Additionally, individual votes are federated over ActivityPub together with the corresponding username. This means that other federated platforms can freely choose how to display vote information, even going as far as publicly displaying individual votes.
