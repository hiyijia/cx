//
// WAV/AU Flash player with resampler
// 
// Copyright (c) 2009, Anton Fedorov <datacompboy@call2ru.com>
//
/* This code is free software; you can redistribute it and/or modify it
 * under the terms of the GNU General Public License version 2 only, as
 * published by the Free Software Foundation.
 *  
 * This code is distributed in the hope that it will be useful, but WITHOUT
 * ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
 * FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * version 2 for more details (a copy is included in the LICENSE file that
 * accompanied this code).
 */

package sx.nme.media.format;
import nme.utils.ByteArray;

// Generic sound-decoder interface.
interface IDecoder {
	// Bytes size of one input chunk
	var sampleSize : Int;
	// Number of PCM samples in one input chunk
	var sampleLength : Int;
	// Decode one input chunk to PCM samples
	function decode( InBuf : ByteArray, InOff: Int, Chan: Int, OutBuf : Array<Float>, OutOff: Int ) : Int;
	// Return output length based on count of input samples
	function decodeLength(chunks: Int) : Int;
}

class Decoder implements IDecoder {
	public var sampleSize : Int;
	public var sampleLength : Int;
	public function decode( InBuf : ByteArray, InOff: Int, Chan: Int, OutBuf : Array<Float>, OutOff: Int ) : Int {
		throw("Please specify in subclass");
		return 0;
	}
	// Common standard decoder 
	public function decodeLength(chunks: Int) : Int {
		return chunks*sampleLength;
	}
}
