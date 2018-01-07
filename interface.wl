(* ::Package:: *)

uiSettings:=DynamicModule[{choices},
	choices=userInfo;
	CreateDialog[Column[{Spacer[{40,40}],
		Style[text[["Settings"]],Bold,28],Spacer[1],
		Grid[{
			{Style[text[["Identity"]]<>": ",20],
				RadioButtonBar[Dynamic@choices[["Developer"]],{False->text[["NormalUser"]],True->text[["Developer"]]}]
			},
			{Style[text[["Language"]]<>": ",20],
				RadioButtonBar[Dynamic@choices[["Language"]],langList]}
			}
		],Spacer[1],
		Row[{
			Button[text[["Save"]],
				userInfo=choices;
				Export[userPath<>"Default.json",Normal@userInfo];
				DialogReturn[QYMP],
			ImageSize->150],
			Spacer[10],
			Button[text[["Return"]],DialogReturn[QYMP],ImageSize->150]
		}],Spacer[{40,40}]
	},Center,ItemSize->40],
	WindowTitle->text[["Settings"]]]
];


PlayerPalette[song_]:={Spacer[{40,40}],
	Row[{Style[index[[song,"SongName"]],Bold,28],
		If[KeyExistsQ[index[[song]],"Comment"],
			Style[" ("<>index[[song,"Comment"]]<>")",Gray,28],
			Nothing
		]
	}],Spacer[1],
	If[KeyExistsQ[index[[song]],"Composer"],tagName[["Composer"]]<>": "<>index[[song,"Composer"]],Nothing],
	If[KeyExistsQ[index[[song]],"Lyricist"],tagName[["Lyricist"]]<>": "<>index[[song,"Lyricist"]],Nothing],
	If[KeyExistsQ[index[[song]],"Adapter"],tagName[["Adapter"]]<>": "<>index[[song,"Adapter"]],Nothing],"",
	If[KeyExistsQ[index[[song]],"Abstract"],
		Column[StringSplit[index[[song,"Abstract"]],"\n"],Left],
		Nothing
	],Spacer[1],
	Row[{
		Dynamic[timeDisplay[current["Position"]]],
		Spacer[8],
		ProgressIndicator[Dynamic[current["Position"]/duration],ImageSize->{240,16}],
		Spacer[8],
		timeDisplay[duration]
	}],Spacer[1],
	Row[{Button[
		Dynamic[Switch[current["State"],
			"Playing",text[["Pause"]],
			"Paused"|"Stopped",text[["Play"]]
		]],
		Switch[current["State"],
			"Playing",current["State"]="Paused",
			"Paused"|"Stopped",current["State"]="Playing"
		],
		ImageSize->80],
		Spacer[20],
		Button[text[["Stop"]],current["State"]="Stopped",ImageSize->80],
		Spacer[20],
		Button[text[["Return"]],AudioStop[];DialogReturn[QYMP],ImageSize->80]			
	}],Spacer[{40,40}]
};


uiPlayer[song_]:=Module[{image,audio,imageExist},
	AudioStop[];
	If[KeyExistsQ[index[[song]],"Image"],
		imageExist=True;image=Import[userPath<>"Images\\"<>index[[song,"Image"]]],
		imageExist=False
	];
	audio=Import[userPath<>"Buffer\\"<>song<>".buffer","MP3"];
	duration=Duration[audio];
	current=AudioPlay[audio];
	CreateDialog[If[imageExist,
		Row[{Spacer[50],
			Column[{
				Spacer[{40,40}],
				Tooltip[Image[image,ImageSize->If[ImageAspectRatio[image]>1,{360,UpTo[720]},{UpTo[800],400}]],
					If[KeyExistsQ[imageData,index[[song,"Image"]]],
						Column[If[KeyExistsQ[imageData[[index[[song,"Image"]]]],#],
							tagName[[#]]<>": "<>imageData[[index[[song,"Image"]],#]],
							Nothing
						]&/@imageTags],
						"\:6682\:65e0\:8be5\:56fe\:7247\:7684\:4fe1\:606f"
					]
				],
				Spacer[{40,40}]
			}],
			Spacer[50],
			Column[PlayerPalette[song],Alignment->Center,ItemSize->30],
		Spacer[50]},Alignment->Center],
		(* no image *)
		Column[PlayerPalette[song],Alignment->Center,ItemSize->50]
	],WindowTitle->text[["Playing"]]<>": "<>index[[song,"SongName"]]];
];


QYMP:=DynamicModule[{song},
	refresh;
	AudioStop[];
	CreateDialog[Column[{Spacer[{40,40}],
		Row[{Style[text[["QYMP"]],Bold,32],Style[" (\:7b2c"<>ToString[page]<>"\:9875)",Gray,32]}],Spacer[1],
		SetterBar[Dynamic@song,
			#->Row[{
				Style[index[[#,"SongName"]],24,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],
				Spacer[20],
				If[KeyExistsQ[index[[#]],"Comment"],Style[index[[#,"Comment"]],20,Gray,FontFamily->"\:5fae\:8f6f\:96c5\:9ed1"],Nothing]
			}]&/@songListPaged[[page]],
			Appearance->"Vertical"
		],"",
		Row[{
			Button[text[["PgPrev"]],DialogReturn[page--;QYMP],ImageSize->200,Enabled->(page>1)],
			Spacer[10],
			Button[text[["PgNext"]],DialogReturn[page++;QYMP],ImageSize->200,Enabled->(page<pageCount)]
		}],
		If[userInfo[["Developer"]],Row[{
			Button[text[["AddSong"]],DialogReturn[uiAddSong],ImageSize->200],
			Spacer[10],
			Button[text[["ModifySong"]],DialogReturn[uiModifySong[song]],ImageSize->200]
		}],Nothing],
		Row[{
			Button[text[["PlaySong"]],DialogReturn[uiPlayer[song]],ImageSize->200],
			Spacer[10],
			Button[text[["Settings"]],DialogReturn[uiSettings],ImageSize->200]
		}],
		Row[{
			Button[text[["About"]],DialogReturn[],ImageSize->200,Enabled->False],
			Spacer[10],
			Button[text[["Exit"]],DialogReturn[],ImageSize->200]
		}],Spacer[{40,40}]
	},Center,ItemSize->50],
	WindowTitle->text[["QYMP"]]]
];


uiModifySong[song_]:=DynamicModule[{textInfo},
	textInfo=getTextInfo[song];
	CreateDialog[Column[{"",
		Style[textInfo[["SongName"]],FontSize->28,Bold],"",
		Grid[{tagName[[#]],Spacer[20],InputField[Dynamic@textInfo[[#]],String]}&/@textInfoTags],"",
		Grid[{
			{Button[text[["Save"]],putTextInfo[song,textInfo],ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
			Button[text[["Undo"]],textInfo=getTextInfo[song],ImageSize->150]},
			{Button[text[["Delete"]],DialogReturn[uiDeleteSong[song]],ImageSize->150],
			Button[text[["Return"]],DialogReturn[QYMP],ImageSize->150]}
		}],""
	},Center,ItemSize->30,Spacings->1],
	WindowTitle->"\:4fee\:6539\:6b4c\:66f2\:4fe1\:606f"];
];


ignoreList={"temp.qys","test.qys"};
uiAddSong:=DynamicModule[{songPath,textInfo,candidates},
	textInfo=AssociationMap[""&,textInfoTags];
	candidates=Complement[StringDrop[FileNames["*.qys"|"*.qym","Songs",Infinity],6],
		#<>"."<>index[[#,"Format"]]&/@songList,
		ignoreList
	];
	CreateDialog[Column[{"",
		Style["\:6dfb\:52a0\:65b0\:66f2\:76ee",FontSize->28,Bold],"",
		Row[{"\:4f4d\:7f6e",Spacer[20],PopupMenu[Dynamic@songPath,candidates,ImageSize->200]}],
		Grid[{tagName[[#]],Spacer[20],InputField[Dynamic@textInfo[[#]],String]}&/@textInfoTags],"",
		Row[{Button[text[["Add"]],
			song=StringDrop[songPath,-4];
			AppendTo[bufferHash,song->toBase32@FileHash[path<>"Songs\\"<>songPath]];
			Export[userPath<>"Buffer.json",Normal@bufferHash];
			audio=If[StringTake[songPath,-3]=="qys",QYSParse,QYMParse][path<>"Songs\\"<>songPath];
			Export[userPath<>"Buffer\\"<>song<>".buffer",audio,"MP3"];
			metaInfo=Values[Options[audio,MetaInformation]][[1]];
			metaInfo[["TrackCount"]]=ToString[metaInfo[["TrackCount"]]];
			metaInfo[["Duration"]]=ToString[metaInfo[["Duration"]],InputForm];
			metaInfo[["Instruments"]]=ToString[metaInfo[["Instruments"]],InputForm];
			AppendTo[index,song->metaInfo];
			putTextInfo[song,textInfo];
			DialogReturn[QYMP],
		ImageSize->150,Enabled->Dynamic[textInfo[["SongName"]]!=""]],
		Spacer[20],
		Button[text[["Return"]],DialogReturn[QYMP],ImageSize->150]}],""
	},Center,ItemSize->30,Spacings->1],
	WindowTitle->"\:6dfb\:52a0\:65b0\:66f2\:76ee"]
];


uiDeleteSong[song_]:=CreateDialog[Column[{"",
	"\:4f60\:786e\:5b9a\:8981\:5c06\:6b4c\:66f2\:300a"<>index[[song,"SongName"]]<>"\:300b\:4ece\:6b4c\:5355\:4e2d\:79fb\:9664\:5417\:ff1f","",
	Row[{
		Button[text[["Confirm"]],
			index=Delete[index,song];
			DeleteFile[path<>"Meta\\"<>song<>".meta"];
			DialogReturn[QYMP],
		ImageSize->100],
		Spacer[20],
		Button[text[["Return"]],DialogReturn[QYMP],ImageSize->100]			
	}],""
},Center,ItemSize->36],
WindowTitle->"\:5220\:9664\:66f2\:76ee"];
