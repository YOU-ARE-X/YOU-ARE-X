using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using UnityEngine.EventSystems;

	/*
	Manages button sizing,
	and communicates click to TextToggle
	*/

public class TextButton : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler {

	private TextToggle toggle;
	private RectTransform t;
	private bool hovering = false;
	private float smallSize = 0.2f;
	private float bigSize = 0.3f;
	private float size = 0.2f;

	void Start() {
		toggle = gameObject.GetComponentInParent<TextToggle>();
		t = GetComponent<RectTransform>();
	}

	void Update() {
		if (hovering && toggle.opened == false) size = God.ease(size, bigSize, 0.05f);
		else size = God.ease(size, smallSize, 0.05f);

		t.localScale = new Vector3(size, size, size);
	}

	public void OnPointerEnter(PointerEventData e) {
		hovering = true;
	}

	public void OnPointerExit(PointerEventData e) {
		hovering = false;
	}

	public void OnPointerClick(PointerEventData e) {
		toggle.opened = !toggle.opened;
	}
}
