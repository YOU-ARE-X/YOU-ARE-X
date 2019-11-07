using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

	/*
	Manages button sizing,
	and communicates click to TextToggle
	*/

public class TextButton : MonoBehaviour {

	public TextToggle textToggle;
	public RectTransform t;
	public bool hovering = false;
	private float smallSize = 0.2f;
	private float bigSize = 0.3f;
	private float size = 0.2f;

	void Start() {
		StartCoroutine(forgetHover());
	}

	void Update() {
		if (hovering && textToggle.opened == false) size = God.ease(size, bigSize, 400f * Time.deltaTime);
		else size = God.ease(size, smallSize, 400f * Time.deltaTime);

		t.localScale = new Vector3(size, size, size);
	}

	public void toggle() {
		textToggle.opened = !textToggle.opened;
	}

	IEnumerator forgetHover() {
		while (true) {
			yield return new WaitForSeconds(0.5f);
			hovering = false;
		}
	}
}