using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIFollowCamera : MonoBehaviour {

	public float distance = 1f;

    void Update() {
        Vector3 targetPosition = Camera.main.transform.position + (Camera.main.transform.forward + new Vector3(0, 0, distance));
		transform.position = targetPosition;
		transform.rotation = Camera.main.transform.rotation;
    }
}