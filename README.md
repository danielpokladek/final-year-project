# Unity Shaderlab & Shadergraph Final Project
#### by Daniel Pokladek. Unity version: 2018.3.0f2. [Development Blog.](https://danielpokladek.wordpress.com/)

---

## Table of contents:
* [Introduction](#introduction)
* [Software & Languages](#software-and-languages)
	* Shaderlab (Cg)
  * Unity Shader Graph
* [Planned Shaders](#planned-shaders)
	* Rainy Surface Shader
  * Photorealistic Ice Shader
  * Borderlands Themed Toon Shader
* [Folders](#folders)
* [To-Do List](#to-do-list)

## Introduction
My name is Daniel Pokladek, and this is the GitHub repository for my dissertation project. For the next year I will be working with Unity’s CG/Shaderlab to create three artefacts that will be my final shaders and the basis for my dissertation grade. Throughout the year, I will also be creating small shaders while learning how shaders are made. This repository contains all of my shaders, together with my final project proposal.  
  
## Software and Languages
For this project I will be using Unity engine as the framework to create the shaders. Unity has a built-in shader language called ‘Shaderlab’ that allows for quicker and easier development of shaders; Shaderlab also allows the shader properties to be editable straight from the editor allowing things to be changed on the go. I will be using Shaderlab alongside with Cg shader language to create my shaders.

As part of the dissertation I will also create those shaders using Unity’s new shader graph technology, using the dissertation as opportunity to gain a lot of experience with the new technology. 

## Planned shaders
As mentioned in the introduction, for my project I will be creating three complex shaders that will be built from few smaller shaders. Creating the smaller components of the complex shaders first, will allow me to gain experience in writing shaders, as well as understanding in how those components work.

* [ ] Rainy Surface Shader  
This will be the first shader I will attempt at creating, it is inspired by DeepSpaceBanana’s [Rainy Surface](https://deepspacebanana.github.io/deepspacebanana.github.io/blog/shader/art/unreal%20engine/Rainy-Surface-Shader-Part-1) shader that he has originally created in Unreal Engine. I will attempt to recreate this shader from scratch in Cg shader language.  

* [ ] Photorealistic Ice Shader  
This will be the second shader I will attempt at creating. For this shader I will create a photorealistic shader, that will make the surface look like ice. For this shader I will need to research things such as light refraction, reflections and how to implement them into Unity.  
	
* [ ] Borderlands Themed Toon Shader  
This will be the final shader I will attempt at creating, it will be a Borderlands themed toon shader. Unlike the previous two, this shader will attempt to recreate the cartoonish and hand drawn look of Borderlands games.  

These will be ticked off, as I have completed them.  

## Folders
* Cg-Shaders:  
This folder contains the Unity project with shaders I have written in Cg, unlike the Shader Graph project, this project uses Unity’s standard rendering pipeline whereas shader graph requires Unity’s lightweight pipeline in order to work.  

* Graph-Shaders:  
This folder contains the Unity project with shaders I have made using Shader Graph, unlike the Cg shaders, shader graph requires Unity’s lightweight rendering pipeline in order to work, thus the two separate projects. This also keeps things clean.  

## To-Do List
This is the to-do list for my shaders.
* Rainy Surface Shader:
	* [X] Research the shader, and it's components.
	* [X] Use the red channel to read the ripple textures.
  	* [X] Use alpha erosion & alpha mask to create the ripples.
	* [X] Lerp two sets of ripples to create a seamless effect.
	* [X] Give users the ability to insert a texture, with a supporting normal map.
  	* [X] Give users the ability to change the colour of the ripples.
	* [X] Add the sub-graph to the main shader file, and compile the effect.
	* [X] Finish the ripples sub-effect.
  * [ ] Create the streaks effect.
  * [ ] Add ability to blend between both effects.
  * [ ] Rainy Surface done.
  
  	* Minor tweaks:
		* [ ] Change time values, to time the lerping better. (currently there is a weird sync problem)
  
* Photorealistic Ice Shader:
	* [ ] Research the shader, and it's components.
  
* Borderlands Themed Toon Shader:
	* [ ] Research the shader, and it's components.
