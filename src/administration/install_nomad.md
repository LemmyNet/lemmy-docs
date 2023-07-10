# Nomad Deployment (unsupported)

Lemmy can be deployed onto a Nomad cluster, which has benefits including:

- distributing services across several machines (you can have the DB on a machine and the backend running on a different one)
- relocating load if a machine fails
- potentially load-balancing across stateless services (like the UI) if desired
- rolling updates for less downtime

The downsides include:

- requiring an existing Nomad cluster already deployed
- extra configuration depending on your existing set-up
- not officially supported

You can see examples of job files that you can use as a starting point at the [Lemmy-Nomad](https://github.com/LemmyNet/lemmy-nomad) repo.
