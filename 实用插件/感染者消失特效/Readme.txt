原地址:
https://forums.alliedmods.net/showthread.php?p=2587658


命令:
!dissolve       // 消失特效


控制台变量
// 0=Plugin off, 1=Plugin on.
l4d_dissolve_allow "1"

// Turn on the plugin in these game modes, separate by commas (no spaces). (Empty = all).
l4d_dissolve_modes ""

// Turn off the plugin in these game modes, separate by commas (no spaces). (Empty = none).
l4d_dissolve_modes_off ""

// Turn on the plugin in these game modes. 0=All, 1=Coop, 2=Survival, 4=Versus, 8=Scavenge. Add numbers together.
l4d_dissolve_modes_tog "0"

// Out of 100 the chance of dissolving a zombie when it dies. Note: stays activate for 0.5 seconds after triggering.
l4d_dissolve_chance "100"

// Dissolve these on death: 1=Common, 2=Witch, 4=Smoker, 8=Boomer, 16=Hunter, 32=Spitter, 64=Jockey, 128=Charger, 256=Tank, 511=All.
l4d_dissolve_infected "511"

// When time_min and time_max are not 0.0 the dissolve time will randomly be set to a value between these.
l4d_dissolve_time_min "0.0"

// When time_min and time_max are not 0.0 the dissolve time will randomly be set to a value between these.
l4d_dissolve_time_max "0.0"

// How long the particles stay for. Recommended values for best results from 0.0 (minimal particles) to 0.8.
l4d_dissolve_time "0.2"

// Dissolve Infected plugin version.
l4d_dissolve_version 