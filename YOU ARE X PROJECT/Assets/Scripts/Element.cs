using System.Collections;
using System.Collections.Generic;
using UnityEngine;

	/*
	Holds information about element:
	name,
	audio set(?),
	zoom level,
	chronologic sequencing.
	*/

public class Element {

	public string elementName;
	public List<ElementScene> scenes = new List<ElementScene>();

	public void init(string n) {
		elementName = n;
	}

	public void createScene(string s, string z, int sq) {
		ElementScene scene = new ElementScene();
		scene.init(s, z, sq);
		scenes.Add(scene);
	}
}

public class ElementScene {

	public string sceneName;
	public string zoom;
	public int sequence;

	public void init(string s, string z, int sq) {
		sceneName = s;
		zoom = "x" + z;
		sequence = sq;
	}
}