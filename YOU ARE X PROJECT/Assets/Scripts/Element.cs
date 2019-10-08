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

	public string name;
	public List<ElementScene> scenes = new List<ElementScene>();

	public Element(string n) {
		name = n;
	}

	public void createScene(string z, int sq) {
		ElementScene scene = new ElementScene(this.name, z, sq);
		scenes.Add(scene);
	}
}

public class ElementScene {

	public string element;
	public string name;
	public string zoom;
	public int sequence;

	public bool loaded = false;

	public ElementScene(string s, string z, int sq) {
		element = s;
		name = s + "-" + sq;
		zoom = "x" + z;
		sequence = sq;
	}
}