using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FadeAudioIn : MonoBehaviour {

	private AudioSource s;

	void Start() {
		s = GetComponent<AudioSource>();
		StartCoroutine(FadeIn());
	}

	IEnumerator FadeIn() {
		yield return new WaitForSeconds(0.8f);

		while (s.volume < 1f) {
			yield return new WaitForSeconds(0.1f);
			s.volume += 0.01f;
		}
	}
}