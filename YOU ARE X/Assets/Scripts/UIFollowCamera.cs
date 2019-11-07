using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UIFollowCamera : MonoBehaviour {

    void Update() {
        Vector3 targetPosition = Camera.main.transform.position + (Camera.main.transform.forward * 3);
		transform.position = targetPosition;
		transform.rotation = Camera.main.transform.rotation;
    }
}