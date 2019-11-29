using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIFollowCamera : MonoBehaviour {

	public float distance = 1f;

    void Update() {
    	GameObject cam = GameObject.Find("Camera");
        Vector3 targetPosition = cam.transform.position + (cam.transform.forward * distance);
		transform.position = targetPosition;
		transform.rotation = cam.transform.rotation;
    }
}