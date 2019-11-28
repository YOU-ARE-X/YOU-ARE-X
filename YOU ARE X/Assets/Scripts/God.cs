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
	private Element[] selectElements = new Element[4];
	private static Random rng = new Random();

	private string[] lines = new string[]
	{
		"Hydrogen",
		"Helium",
		"Lithium",
		"Beryllium",
		"Boron",
		"Carbon",
		"Nitrogen",
		"Oxygen",
		"Fluorine",
		"Neon",
		"Sodium",
		"Magnesium",
		"Aluminum",
		"Silicon",
		"Phosphorus",
		"Sulfur",
		"Chlorine",
		"Argon",
		"Potassium",
		"Calcium",
		"Scandium",
		"Titanium",
		"Vanadium",
		"Chromium",
		"Manganese",
		"Iron",
		"Cobalt",
		"Nickel",
		"Copper",
		"Zinc",
		"Gallium",
		"Germanium",
		"Arsenic",
		"Selenium",
		"Bromine",
		"Krypton",
		"Rubidium",
		"Strontium",
		"Yttrium",
		"Zirconium",
		"Niobium",
		"Molybdenum",
		"Technetium",
		"Ruthenium",
		"Rhodium",
		"Palladium",
		"Silver",
		"Cadmium",
		"Indium",
		"Tin",
		"Antimony",
		"Tellurium",
		"Iodine",
		"Xenon",
		"Cesium",
		"Barium",
		"Lanthanum",
		"Cerium",
		"Praseodymium",
		"Neodymium",
		"Promethium",
		"Samarium",
		"Europium",
		"Gadolinium",
		"Terbium",
		"Dysprosium",
		"Holmium",
		"Erbium",
		"Thulium",
		"Ytterbium",
		"Lutetium",
		"Hafnium",
		"Tantalum",
		"Tungsten",
		"Rhenium",
		"Osmium",
		"Iridium",
		"Platinum",
		"Gold",
		"Mercury",
		"Thallium",
		"Lead",
		"Bismuth",
		"Polonium",
		"Astatine",
		"Radon",
		"Francium",
		"Radium",
		"Actinium",
		"Thorium",
		"Protactinium",
		"Uranium",
		"Neptunium",
		"Plutonium",
		"Americium",
		"Curium",
		"Berkelium",
		"Californium",
		"Einsteinium",
		"Fermium",
		"Mendelevium",
		"Nobelium",
		"Lawrencium",
		"Rutherfordium",
		"Dubnium",
		"Seaborgium",
		"Bohrium",
		"Hassium",
		"Meitnerium",
		"Darmstadtium",
		"Roentgenium",
		"Copernicium",
		"Nihonium",
		"Flerovium",
		"Moscovium",
		"Livermorium",
		"Tennessine",
		"Oganesson"
	};
	private string longLines;
	private Element human;

	public Text you;
	public Text are;
	public Text x;
	public CanvasGroup t;
	public CanvasGroup ui;
	public CanvasGroup blocker;

	void Start() {
		DontDestroyOnLoad(this.gameObject);

		//create all elements (name) with scenes (zoom, sequence)
		elements.Add(new Element("Wood"));
		elements[0].createScene("400", 1);
		elements[0].createScene("400", 2);

		elements.Add(new Element("Salt"));
		elements[1].createScene("400", 1);
		elements[1].createScene("400", 2);

		elements.Add(new Element("Copper"));
		elements[2].createScene("400", 1);
		elements[2].createScene("400", 2);

		elements.Add(new Element("Helium"));
		elements[3].createScene("400", 1);
		elements[3].createScene("400", 2);

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
		blocker.alpha = 1f;
		t.alpha = 1f;
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
		ui.alpha = 0f;
		SceneManager.LoadScene(1); //loader ID in build settings
		sceneReference++;

		if (sceneReference >= scenes.Count) {
			youAreText(human.scenes[0]);
			return;
		}

		youAreText(scenes[sceneReference]);
	}

	//load scene and measures time to switch scene
	private void loadScene(ElementScene s) {
		blocker.alpha = 0f;
		t.alpha = 0f;
		SceneManager.LoadScene(s.name);
		loadUI(s);
		
		if (s.name == "Human") return;
		StartCoroutine(time());
	}

	//update UI on scene load
	private void loadUI(ElementScene s) {
		ui.alpha = 1f;

		Text z = GameObject.Find("UI/Zoom").GetComponent<Text>();
		Text e = GameObject.Find("UI/Element").GetComponent<Text>();

		if (z) z.text = s.zoom;
		if (e) e.text = s.name;
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
		while(rect.anchoredPosition.y < 973f) {
			rect.anchoredPosition = new Vector2(rect.anchoredPosition.x, ease(rect.anchoredPosition.y, 975, 2f));
			yield return new WaitForSeconds(0.001f);
		}
		yield return new WaitForSeconds(2);
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