using UnityEngine;

namespace Assets.Scripts.Cam.Effects {
	
	[ExecuteInEditMode]
	[RequireComponent(typeof(UnityEngine.Camera))]
	[AddComponentMenu("Image Effects/Custom/Kirsch")]

	public class Kirsch : MonoBehaviour {
		private Material m_material;
		private Shader shader;

        public float blend = 0.25f;
        public bool tanh = true;
        public float slope = 1.0f;

        private Material material {
			get {
				if (m_material == null) {
					shader = Shader.Find("Kirsch");
					m_material = new Material(shader) {hideFlags = HideFlags.DontSave};
				}
				return m_material;
			}
		}

		public void OnRenderImage(RenderTexture src, RenderTexture dest) {
            blend = Mathf.Clamp(blend, 0.0f, 1.0f);

            material.SetFloat("blend", blend);
            material.SetInt("usetanh", (tanh ? 1 : 0));
            material.SetFloat("slope", slope);

            if (material) Graphics.Blit(src, dest, material);
		}
	}
}