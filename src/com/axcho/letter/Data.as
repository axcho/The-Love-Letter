package com.axcho.letter 
{
	/**
	 * ...
	 * @author axcho
	 */
	public class Data 
	{
		
		[Embed(source = 'data/snd_school_music.mp3')] static public const SndSchoolMusic:Class;
		[Embed(source = 'data/snd_letter_music.mp3')] static public const SndLetterMusic:Class;
		
		[Embed(source = 'data/snd_bell.mp3')] static public const SndBell:Class;
		[Embed(source = 'data/snd_button_click.mp3')] static public const SndButtonClick:Class;
		[Embed(source = 'data/snd_button_hover.mp3')] static public const SndButtonHover:Class;
		[Embed(source = 'data/snd_caught.mp3')] static public const SndCaught:Class;
		[Embed(source = 'data/snd_door_close.mp3')] static public const SndDoorClose:Class;
		[Embed(source = 'data/snd_door_open.mp3')] static public const SndDoorOpen:Class;
		[Embed(source = 'data/snd_highlight.mp3')] static public const SndHighlight:Class;
		[Embed(source = 'data/snd_kiss.mp3')] static public const SndKiss:Class;
		[Embed(source = 'data/snd_locker_open.mp3')] static public const SndLockerOpen:Class;
		[Embed(source = 'data/snd_text_close.mp3')] static public const SndTextClose:Class;
		[Embed(source = 'data/snd_text_open.mp3')] static public const SndTextOpen:Class;
		[Embed(source = 'data/snd_student_talk01.mp3')] static public const SndStudentTalk01:Class;
		[Embed(source = 'data/snd_student_talk02.mp3')] static public const SndStudentTalk02:Class;
		[Embed(source = 'data/snd_student_talk03.mp3')] static public const SndStudentTalk03:Class;
		static public const SndStudentTalks:Array = [SndStudentTalk01, SndStudentTalk02, SndStudentTalk03];
		
	}

}