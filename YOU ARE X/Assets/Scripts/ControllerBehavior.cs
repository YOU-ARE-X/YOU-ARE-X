using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Valve.VR;

public class ControllerBehavior : MonoBehaviour {

	public SteamVR_Action_Boolean triggerUI;
	public SteamVR_Input_Sources handType;
	private bool ready = true;

	void Start() {
		triggerUI.AddOnStateDownListener(TriggerDown, handType);
		triggerUI.AddOnStateUpListener(TriggerUp, handType);
	}

	void Update() {
		//raycast for hover
		RaycastHit hit;

		if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit, Mathf.Infinity)) {
			if (hit.collider.tag == "TextToggle") {
				hit.transform.gameObject.GetComponent<TextButton>().hovering = true;
			}
		}
	}

	public void TriggerUp(SteamVR_Action_Boolean fromAction, SteamVR_Input_Sources fromSource) {
		ready = true;
	}

	public void TriggerDown(SteamVR_Action_Boolean fromAction, SteamVR_Input_Sources fromSource) {
		if (ready) {
			ready = false;

			RaycastHit hit;

			//cast ray - if hits ui, toggle ui
			if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out hit, Mathf.Infinity)) {
				if (hit.collider.tag == "TextToggle") {
					hit.transform.gameObject.GetComponent<TextButton>().toggle();
				}
			}
		}
	}
}