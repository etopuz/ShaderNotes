## Shaders And CG Notes On Unity
Experiments and notes based on different sources. This page shows the effects and key points of codes. Also for each experiment there is link to see full codes.

## Sources
- [The Unity Shaders Bible](https://www.jettelly.com/store/books/the-unity-shaders-bible/)
- [Freya Holmér's Shader Video Series](https://www.youtube.com/watch?v=kfM-yu0iQBk&list=PLImQaTpSAdsCnJon-Eir92SZMl7tPBS4Z)

Many thanks to the creators of these valuable sources.

## Experiments

### Experiment_002 Stencil Shader

![Hole Mechanic From Donut County](media/exp002_stencil/stencil_hole_donut_county.gif)

![StencilMask Shader](media/exp002_stencil/StencilMask.png)

![StencilBlocked Shader](media/exp002_stencil/StencilBlocked.png)

[See Full Stencil Shader Codes](Assets/Experiments/Experiment2_Stencil/Code/Shaders)

### Experiment_003 Kaleidoscope Effect

![Kaleidoscope Effect](media/exp003_kaleidoscope/kaleidoscope.gif)

![Kaleidoscope Shader](media/exp003_kaleidoscope/kaleidoscope_shader.png)

[See Full Kaleidoscope Effect Shader Codes](Assets/Experiments/Experiment3_Kaleidoscope/Code/Shaders/Kaleidoscope.shader)

**Note**: Unity_Rotate_Degrees_float is a function written by Unity included in Shader Graph. The function rotates value of input UV around a reference point defined by input Center by the amount of input rotation. [See in Shader Graph Manual](https://docs.unity3d.com/Packages/com.unity.shadergraph@7.1/manual/Rotate-Node.html)

### Experiment_004 Zoom Effect

![Zoom Effect](media/exp004_zoom/ZoomEffect.gif)
![Kaleidoscope Shader](media/exp004_zoom/ZoomEffectShader.png)
\
[See Full Zoom Effect Shader Codes](Assets/Experiments/Experiment4_Zoom/Code/Shaders/ZoomShader.shader)



