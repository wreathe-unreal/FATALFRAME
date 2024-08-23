using UnityEngine;
using UnityEngine.Video;

public class TVInteraction : Item
{
    public MeshRenderer displayTV;
    public Light displayPointLight;

    [Space]
    public Material OffMaterial;
    public Material RenderMaterial;

    [Space]
    public VideoPlayer displayVideoPlayer;

    [Space]
    public string TVSound;

    private RenderTexture videoRenderTexture;

    public Vector2Int renderTextureSize = new Vector2Int(512, 512);

    protected bool isTV = false;

    private void Start()
    {
        displayPointLight.enabled = isTV;
        displayTV.material = OffMaterial;

        displayVideoPlayer.audioOutputMode = VideoAudioOutputMode.AudioSource;
        displayVideoPlayer.source = VideoSource.VideoClip;

        videoRenderTexture = new RenderTexture(renderTextureSize.x, renderTextureSize.y, 0);
        displayVideoPlayer.targetTexture = videoRenderTexture;
        RenderMaterial.mainTexture = videoRenderTexture;
    }

    public override void ActivateObject()
    {
        isTV = !isTV;
        AudioManager.instance.Play(TVSound);

        UpdateTVState();
    }

    private void UpdateTVState()
    {
        displayPointLight.enabled = isTV;

        if (isTV)
        {
            displayTV.material = RenderMaterial;
            displayVideoPlayer.Play();
        }
        else
        {
            displayTV.material = OffMaterial;
            displayVideoPlayer.Pause();
        }
    }
}
