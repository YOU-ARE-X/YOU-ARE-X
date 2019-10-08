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

	private int sceneReference = 0;
	private int secondsPerScene = 5;

	private List<Element> elements = new List<Element>();
	private List<ElementScene> scenes = new List<ElementScene>();
	private Element[] selectElements = new Element[6];
	private static Random rng = new Random();

	private string[] lines = new string[]{"Borium","Water","Dirt","Nitrogen"};
	private Element human;
	public Scene loader;

	void Start() {
		DontDestroyOnLoad(this.gameObject);

		//create all elements (name) with scenes (name, zoom, sequence)
		elements.Add(new Element("Silicon"));
		elements[0].createScene("400", 1);
		elements[0].createScene("400", 2);
		elements[0].createScene("400", 3);

		elements.Add(new Element("Methane"));
		elements[1].createScene("400", 1);
		elements[1].createScene("400", 2);

		elements.Add(new Element("Helium"));
		elements[2].createScene("400", 1);
		elements[2].createScene("400", 2);

		elements.Add(new Element("Water"));
		elements[3].createScene("400", 1);
		elements[3].createScene("400", 2);
		elements[3].createScene("400", 3);

		elements.Add(new Element("Carbon"));
		elements[4].createScene("400", 1);
		elements[4].createScene("400", 2);

		elements.Add(new Element("Gold"));
		elements[5].createScene("400", 1);
		elements[5].createScene("400", 2);
		elements[5].createScene("400", 3);

		elements.Add(new Element("Bacteria"));
		elements[6].createScene("400", 1);
		elements[6].createScene("400", 2);
		elements[6].createScene("400", 3);

		elements.Add(new Element("Copper"));
		elements[7].createScene("400", 1);
		elements[7].createScene("400", 2);

		elements.Add(new Element("Pesticide"));
		elements[8].createScene("400", 1);
		elements[8].createScene("400", 2);

		elements.Add(new Element("Bark"));
		elements[9].createScene("400", 1);
		elements[9].createScene("400", 2);
		elements[9].createScene("400", 3);

		human = new Element("Human");
		human.createScene("1", 1);

		//randomize element order
		for (int i = 0; i < elements.Count; i++) {
			Element temp = elements[i];
			int randomIndex = Random.Range(i, elements.Count);
			elements[i] = elements[randomIndex];
			elements[randomIndex] = temp;
		}

		//pick set of 6 elements from all
		for (int i = 0; i < selectElements.Length; i++) {
			selectElements[i] = elements[i];
		}

		//create sequence of scenes from elements
		//keep sequence of each element's scenes
		int totalScenes = 0;
		for (int i = 0; i < selectElements.Length; i++) {
			totalScenes += selectElements[i].scenes.Count;
		}

		while (scenes.Count < totalScenes) {
			Element randomElement = selectElements[Random.Range(0, selectElements.Length)];
			for (int i = 0; i < randomElement.scenes.Count; i++) {
				if (randomElement.scenes[i].loaded) continue;
				else {
					randomElement.scenes[i].loaded = true;
					scenes.Add(randomElement.scenes[i]);
					break;
				}
			} 
		}

		youAreText(scenes[sceneReference]);
	}

	//text sequence
	private void youAreText(ElementScene s) {
		string x = s.element;
		string big = "";

		for (int i = 0; i < 200; i++) {
			big += "\n" + lines[Random.Range(0, lines.Length)];
		}

		//TODO: add text animation

		loadScene(s);
	}

	//end scene, and load Loader scene
	private void endScene() {
		SceneManager.LoadScene(loader.name);
		sceneReference++;

		if (sceneReference >= scenes.Count) {
			youAreText(human.scenes[0]);
			return;
		}

		youAreText(scenes[sceneReference]);
	}

	//load scene and measures time to switch scene
	private void loadScene(ElementScene s) {
		SceneManager.LoadScene(SceneManager.GetSceneByName(s.name).name);
		if (s.name == "Human") return;
		StartCoroutine(time());
	}

	IEnumerator time() {
		yield return new WaitForSeconds(secondsPerScene);
		endScene();
	}
}