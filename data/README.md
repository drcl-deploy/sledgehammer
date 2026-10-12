# Frozen V9.3 data

`sys1_clips.npz` is the clip table; `sys1_library.npz` records its source library.
`sys1_bundle.npz` carries the selected frames, including body contact commands.
`sys1_walk/` provides the approach and disarmed walking motion. The V9.3 configs
load these installed package files without a training checkout or asset-root override.

The bundle was baked with the extracted C++ loader and compared byte-for-byte
across all four arrays against the original Phase 0 snapshot. `data.lock.json`
records payload hashes, source revisions and motion companion hashes.

Rebaking from the original dataset requires each motion's `contact_matrix.npz`
and `object_motion.npz` siblings. Omitting the contact sidecars silently yields
zero contact commands in the legacy loader. Earlier relocation smoke tests did
not catch that omission; Phase 5 restored the inputs and verified the full rows.
The packaged bundle includes those contacts and does not require the sidecars.
