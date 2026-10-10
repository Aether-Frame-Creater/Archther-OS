-- Monitor configuration: permissive defaults, no machine-specific output
-- names, resolutions, or scale factors. Adjust per machine when a second
-- display is introduced; never hardcode one laptop's outputs as universal.
-- See https://wiki.hypr.land/Configuring/Basics/Monitors/

hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})
