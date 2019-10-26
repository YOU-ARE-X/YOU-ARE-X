using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

	/*
	Manages game text -
	toggles a text on and off,
	and billboards towards camera
	*/

public class TextToggle : MonoBehaviour {

	private Text text;
	private RectTransform lineLeft;
	private RectTransform lineRight;
	private GameObject cam;

	public bool opened = false;

	void Start() {
		text = gameObject.transform.Find("Text").gameObject.GetComponent<Text>();
		lineLeft = gameObject.transform.Find("Line Left").gameObject.GetComponent<RectTransform>();
		lineRight = gameObject.transform.Find("Line Right").gameObject.GetComponent<RectTransform>();
		cam = GameObject.Find("Camera");
	}

	void Update() {
		//aim towards camera
		transform.rotation = Quaternion.LookRotation(transform.position - cam.transform.position);

		//toggle state
		if (opened) {
			text.color = new Color(1, 1, 1, God.ease(text.color.a, 1, 5f));
			lineLeft.sizeDelta = new Vector2(God.ease(lineLeft.sizeDelta.x, 60, 5f), 100);
			lineRight.sizeDelta = new Vector2(God.ease(lineLeft.sizeDelta.x, 60, 5f), 100);

		} else {
			text.color = new Color(1, 1, 1, God.ease(text.color.a, 0, 5f));
			lineLeft.sizeDelta = new Vector2(God.ease(lineLeft.sizeDelta.x, 0, 5f), 100);
			lineRight.sizeDelta = new Vector2(God.ease(lineLeft.sizeDelta.x, 0, 5f), 100);
		}
	}
}