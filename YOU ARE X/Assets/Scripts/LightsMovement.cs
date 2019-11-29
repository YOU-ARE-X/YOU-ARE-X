using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LightsMovement : MonoBehaviour {

	Coroutine routine;

	void Start() {
		float r = Random.Range(0f, 1f);

		if (r < 0.5f) {
			transform.position = new Vector3(transform.position.x, transform.position.y, 80f);
		} else {
			transform.position = new Vector3(transform.position.x, transform.position.y, -80f);
		}
	}

	void Update() {
		float r = Random.Range(0f, 1f);

		if (r < 0.005f) {
			if (routine != null) StopCoroutine(routine);
			routine = StartCoroutine(Move());
		}
	}

	IEnumerator Move() {
		float sine = 0f;
		float r = Random.Range(0f, 1f);

		if (r < 0.5f) {
			sine = 80f;
			while (sine > -80f) {
				yield return new WaitForSeconds(0.01f);
				sine = God.ease(sine, -80f, 4f);
        		transform.position = new Vector3(transform.position.x, transform.position.y, sine);
			}
		} else {
			sine = -80f;
			while (sine < 80f) {
				yield return new WaitForSeconds(0.01f);
				sine = God.ease(sine, 80f, 4f);
        		transform.position = new Vector3(transform.position.x, transform.position.y, sine);
			}
		}
	}
}