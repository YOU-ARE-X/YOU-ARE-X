using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookAtCamera : MonoBehaviour {
	void Update() {
		transform.LookAt(-Camera.main.transform.position);
		transform.Rotate(0, 180f, 0);
	}
}