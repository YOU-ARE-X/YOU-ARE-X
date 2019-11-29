using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SlowlyRotate : MonoBehaviour {
    void FixedUpdate() {
        transform.Rotate(Random.Range(0.0f, 0.02f), Random.Range(0.0f, 0.02f), Random.Range(0.0f, 0.02f), Space.Self);
    }
}
