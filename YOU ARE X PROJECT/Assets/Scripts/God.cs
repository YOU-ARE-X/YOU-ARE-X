using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

	/*
	Creates a scene sequence at start,
	calculates time spent in each scene,
	and loads scenes.
	*/

public class God : MonoBehaviour {

	private float timer;
	private int secondsPerScene = 60;
	private List<Element> elements = new List<Element>();
	public Scene loader;
	private static Random rng = new Random();

	void Start() {
		DontDestroyOnLoad(this.gameObject);

		//create all elements
		elements.Add(createElement("Silicon"));
		elements[0].createScene("Silicon1", "400", 1);
		elements[0].createScene("Silicon2", "400", 2);

		//randomize element order
		for (int i = 0; i < elements.Count; i++) {
			Element temp = elements[i];
			int randomIndex = Random.Range(i, elements.Count);
			elements[i] = elements[randomIndex];
			elements[randomIndex] = temp;
		}

		//create sequence of scenes
		
	}

	private Element createElement(string n) {
		Element e = new Element();
		e.init(n);
		return e;
	}

	//end scene, and load Loader scene
	private void endScene() {

	}

	//load scene and measures time to switch scene
	private void loadScene() {

	}
}