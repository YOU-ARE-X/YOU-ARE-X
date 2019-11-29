using UnityEngine;

namespace Assets.Scripts.Cam.Effects {
	[ExecuteInEditMode]
	[RequireComponent(typeof(UnityEngine.Camera))]
	[AddComponentMenu("Image Effects/Custom/EyeDiscarder")]

	public class EyeDiscarder : MonoBehaviour {

        private bool currentEye = true;
        private RenderTexture copiedEye;

        public void OnRenderImage(RenderTexture src, RenderTexture dest) {
            if(currentEye) {
				Graphics.Blit(src, dest);
                Graphics.Blit(src, copiedEye);
			} else {
				Graphics.Blit(copiedEye, dest);
			}
			currentEye = !currentEye;
		}
	}
}