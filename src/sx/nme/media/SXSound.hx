package sx.nme.media;
import nme.events.SampleDataEvent;
import nme.media.Sound;
import nme.media.SoundChannel;
import nme.utils.ByteArray;

/**
 * ...
 * @author Jonas Nyström
 */

class SXSound 
{
		
	/*
	 * *********************************************************
	 * PRIVATE MEMBERS
	 * *********************************************************
	 *
	*/
	
	private var _sound:Sound;
	private var _soundChannel:SoundChannel;
	private var _soundData:ByteArray;
	private var _bufferLenght:Int;
	private var _pos:Int;
	
	/*
	 * *********************************************************
	 * CONSTRUCTOR
	 * *********************************************************
	 *
	*/
	
	public function new(soundData:ByteArray=null) {
		_sound = new Sound();
		//_soundChannel = new SoundChannel();		
		_sound.addEventListener(SampleDataEvent.SAMPLE_DATA, onSampleData);		
		_soundData = soundData;
		_bufferLenght = 2048 * 4 * 2;
		_pos = 0;
	}
	
	
	/*
	 * *********************************************************
	 * 
	 * *********************************************************
	 *
	*/	
	
	private function onSampleData(e:SampleDataEvent):Void {
		trace([_soundData.position, _soundData.length]);
		_pos = _soundData.position;
		
		if (_pos < _soundData.length - _bufferLenght) {
			for (i in 0...2048) {		
				var left:Float = _soundData.readFloat();
				var right:Float = _soundData.readFloat();				
				e.data.writeFloat(left);
				e.data.writeFloat(right);
			}
			return;
		}
		
		for (i in 0...2048) {		
			e.data.writeFloat(0);
			e.data.writeFloat(0);
		}	
	}
	
	

	/*
	 * *********************************************************
	 * PUBLIC METHODS
	 * *********************************************************
	 *
	*/	
	
	public function setSoundData(soundData:ByteArray) {
		_soundData = soundData;
		_soundData.position = 0;
	}
	
	public function testPlay() {		
		_soundChannel = _sound.play();		
	}
	
	public function testStop() {
		_soundChannel.stop();
	}
	
	
}