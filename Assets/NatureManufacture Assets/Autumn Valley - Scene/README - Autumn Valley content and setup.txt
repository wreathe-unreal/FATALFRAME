
To run this scene/level you need our:
- river auto material 2019 https://assetstore.unity.com/packages/tools/terrain/r-a-m-2019-river-auto-material-2019-145937?aid=1011lGkb
- mountain environment - dynamic nature https://assetstore.unity.com/packages/3d/vegetation/mountain-environment-dynamic-nature-191851?aid=1011l7vc
- forest environment - dynamic nature https://assetstore.unity.com/packages/3d/vegetation/forest-environment-dynamic-nature-150668?aid=1011lGkb
assets inside project.

Unity: HD and URP
To run HD or URP versions please visit HD and URP Support Packs folder and import proper hd or urp support pack for your engine version.
Make note that mountain environment,forest environment - dynamic nature, river auto material 2019 should be in hd or urp versions before that operation.
Details you could find in their hd and urp support pack folders.
So steps will be:
1. import all this 3 assets
2. Import their hd or urp support packs + check their readme (each pack have own "hd and urp support packs" folder)
3. Import hd or urp support pack for Autumn Valley. 
All this steps should take 10min.

Unity Standard:
After you import this pack please:
- import unity post processing 2 if you want to use unity post process. It's in unity package manager. Window -> Package Manager -> Post Processing
- change quality level to ultra
- change color space at player settings to linear as we setup pack to linear rendering
- change render type at graphics settings to deferred. We use many reflection probes at scene and at forward they could be heavy. 
Ofc you can switch them off and use forward rendering aswell. We set deferred at our camera too.
- if fps is avarage you could reduce LOD BIAS to 1.5 or 1 in most cases it will help alot for lower end devices.

If you want to replace asphalt road by dirt one you have to open "R.A.M Splines" in hierarchy then turn off: RamSpline_Asphalt and turn on: RamSpline_Dirty_Road objects.

