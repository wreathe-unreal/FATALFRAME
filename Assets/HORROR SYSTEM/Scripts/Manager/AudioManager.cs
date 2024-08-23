using UnityEngine;
using UnityEngine.Audio;

public class AudioManager : MonoBehaviour
{
    [System.Serializable]
    public class SoundSettings
    {
        public string name;
        public AudioClip clip;
        [Range(0f, 1f)] public float volume = .75f;
        [Range(0f, 1f)] public float volumeVariance = .1f;
        [Range(.1f, 3f)] public float pitch = 1f;
        [Range(0f, 1f)] public float pitchVariance = .1f;
        public bool loop = false;
        public AudioMixerGroup mixerGroup;
        public AudioSource source;
    }

    [Header("Sounds")]
    public SoundSettings[] interactionSounds;
    public SoundSettings[] playerSounds;

    public static AudioManager instance;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Destroy(gameObject);
            return;
        }

        InitializeSoundSettings(interactionSounds);
        InitializeSoundSettings(playerSounds);
    }

    private void InitializeSoundSettings(SoundSettings[] sounds)
    {
        foreach (var sound in sounds)
        {
            sound.source = gameObject.AddComponent<AudioSource>();
            sound.source.clip = sound.clip;
            sound.source.volume = sound.volume;
            sound.source.pitch = sound.pitch;
            sound.source.loop = sound.loop;
            sound.source.outputAudioMixerGroup = sound.mixerGroup;
        }
    }

    public void Play(string soundName)
    {
        SoundSettings sound = FindSound(soundName);
        if (sound != null)
        {
            sound.source.volume = sound.volume * (1 + Random.Range(-sound.volumeVariance / 2, sound.volumeVariance / 2));
            sound.source.pitch = sound.pitch * (1 + Random.Range(-sound.pitchVariance / 2, sound.pitchVariance / 2));
            sound.source.Play();
        }
        else
        {
            Debug.LogWarning("The sound with the name " + soundName + " was not found!");
        }
    }

    public void StopPlaying(string soundName)
    {
        SoundSettings sound = FindSound(soundName);
        if (sound != null)
        {
            sound.source.Stop();
        }
        else
        {
            Debug.LogWarning("The sound with the name " + soundName + " was not found!");
        }
    }

    private SoundSettings FindSound(string soundName)
    {
        SoundSettings sound = System.Array.Find(interactionSounds, s => s.name == soundName);
        if (sound == null)
        {
            sound = System.Array.Find(playerSounds, s => s.name == soundName);
        }
        return sound;
    }
}
