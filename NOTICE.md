# Source provenance

The planner was extracted from `drcl-deploy/cpp_control` at
`fe153e4` (V9.3 algorithm baseline `934878e`). That package declares the
MIT license. Existing authorship and comments are retained.

Only file/include paths and build/package integration change during extraction.
The internal `cpp_control::planners::repose` namespace is retained to avoid
unrelated algorithm changes. ROS message types remain `cpp_control/msg/*`.
Shared motion and task-contract utilities are linked from cpp_control's exported
libraries; they are not copied here.
