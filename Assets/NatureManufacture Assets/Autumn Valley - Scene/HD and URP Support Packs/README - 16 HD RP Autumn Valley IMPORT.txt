BEFORE YOU START:
- you need Unity  2023.2 or higher 
- you need HD SRP pipeline 16.0 if you use higher etc custom shaders could not work but seems they should. 
That's why we provide 16.0 version which seems to work with much higher versions aswell. 
For all higher RP versions please use/import 16.0 HD RP support pack.

Be patient this tech is so fluid... we coudn't follow every beta version

Step 1 
	- !!!! IMPORTANT !!!! Open "Project settings" ->"Gaphics"-> "HDRP global settings" ->  "Diffusion Profile Assets"
	and drag and drop our SSS settings diffusion profiles for foliage and water into Diffusion profile list:
		NM_SSSSettings_Skin_NM Foliage Autumn
		NM_SSSSettings_Water_Forest
		NM_SSSSettings_Skin_NM Foliage
		NM_SSSSettings_Skin_NM Foliage Trees Mountain
		NM_SSSSettings_Skin_NM Foliage Mountain
		NM_SSSSettings_Water_Mountain
	If you made this step for forest,mountain and river after you import hd rp support packs be sure you add "NM_SSSSettings_Skin_NM Foliage Autumn"
	We made this profile directly for this scene.
    Without this foliage, water materials will not become affected by scattering and they will look wrong.

	- Open "HDRPMediumQuality" in project settings or "HDRPHighQuality" depends what unity use i your projectas default and:
	 set LOD Bias = 1 or 1.5 for high end device 2 (it will eat cpu mostly as more objects will be rendered and refreshed by cpu)

Step 2 Go to project settings and quality and set:
	- Set VSync to don't sync

Step 3 Find "Autumn Valley Scene" and open it.

Step 4 - HIT PLAY!:)

Step 5 -  Make note that unity often compile shaders even after you hit play for long time, so performance will rise up after unity end shader compilation
Wait a moment until it end. 
At urp and hd rp seams unity SRP batched batches are not counted as saved by batching so they can lead to misunderstanding.
At unity standard render scene got 800-1200 batches and rest is saved by batching. 
At hd and urp there is alot more batches in counter but unity don't show how much of them are batched by srp batcher.
In the past unity count srp batches into save by batching now it's not. We use srp batcher in hd and urp scenes so stats value can lead to misunderstanding. 

About scene construction:
		- There is post process and render profile: Volume Global.
		- Prefab wind manage wind speed and direction at the scene
		- You could adjust fog resolution, we set it to low as it's actualy most expensive thing at scene. For better devices you could use medium quality.
		- Remember to have "always refresh" at scene window turned on, its in "toggle skybox, fog and varous other effect". You can find it
		at top right at scene window. Without this option turned off fog and wind will not refresh properly at scene view, will work only at  playmode.

Play with it, give us feedback and learn about hd srp power.

IMPORTANT:
If you notice in console error:
No more space in Reflection Probe Atlas. To solve this issue, increase the size of the Reflection Probe Atlas in the HDRP settings.
UnityEngine.GUIUtility:ProcessEvent (int,intptr,bool&)
Just change reflection atlas size at hd rp settings into 4kx8k. 