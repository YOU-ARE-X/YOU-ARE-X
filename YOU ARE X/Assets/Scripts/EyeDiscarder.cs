using UnityEngine;

namespace Assets.Scripts.Cam.Effects {
	[ExecuteInEditMode]
	[RequireComponent(typeof(UnityEngine.Camera))]
	[AddComponentMenu("Image Effects/Custom/EyeDiscarder")]

	public class EyeDiscarder : MonoBehaviour {

        private bool currentEye = true;
        private RenderTexture copiedEye;

        public void OnRenderImage(RenderTexture source, RenderTexture destination) {
            if(copiedEye == null) {
                copiedEye = new RenderTexture(source.width, source.height, 0);
            }

            if(currentEye) {
				Graphics.Blit(source, destination);
                Graphics.Blit(source, copiedEye);
			} else {
				Graphics.Blit(copiedEye, destination);
			}

			currentEye = !currentEye;
		}
	}
}