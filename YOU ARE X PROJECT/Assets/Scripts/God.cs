using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

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
	private string longLines;
	private Element human;
	public Scene loader;

	public Text you;
	public Text are;
	public Text x;

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
		//make text invisible
		if (you) you.color = new Color(255,255,255,0);
		if (are) are.color = new Color(255,255,255,0);
		if (x) x.color = new Color(255,255,255,0);

		string xText = s.element;
		longLines = "";

		for (int i = 0; i < 200; i++) {
			longLines += "\n" + lines[Random.Range(0, lines.Length)];
		}

		longLines += "\n" + xText;
		longLines = longLines.ToUpper();

		StartCoroutine(textSequence(s));
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

	IEnumerator textSequence(ElementScene s) {
		yield return new WaitForSeconds(1);
		you.color = new Color(255,255,255,255);
		yield return new WaitForSeconds(1);
		are.color = new Color(255,255,255,255);
		yield return new WaitForSeconds(1);
		x.text = longLines;
		x.color = new Color(255,255,255,255);
		RectTransform rect = x.gameObject.GetComponent<RectTransform>();
		rect.anchoredPosition = new Vector2(rect.anchoredPosition.x, -950);
		while(rect.anchoredPosition.y < 969.9f) {
			rect.anchoredPosition = new Vector2(rect.anchoredPosition.x, ease(rect.anchoredPosition.y, 970, 1f));
			yield return new WaitForSeconds(0.001f);
		}
		yield return new WaitForSeconds(10);
		loadScene(s);
	}

	//statics

	public static float ease(float val, float target, float ease) {
		if (val == target) return val;

		float difference = target - val;
		return val += ((difference * ease) * Time.deltaTime);
	}

	public static float remap(float val, float min1, float max1, float min2, float max2) {
		if (val < min1) val = min1;
		if (val > max1) val = max1;

		return (val - min1) / (max1 - min1) * (max2 - min2) + min2;
	}
}