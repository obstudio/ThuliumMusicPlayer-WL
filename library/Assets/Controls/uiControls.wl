(* ::Package:: *)

uiPlayerControlsOld := With[{StatusAlias = Thulium`System`Private`StatusAlias}, {
	Row[{
		Dynamic[Style[timeDisplay[$CurrentStream["Position"]],20]],
		Spacer[8],
		ProgressIndicator[Dynamic[$CurrentStream["Position"]/$CurrentDuration],ImageSize->{240,16}],
		Spacer[8],
		Style[timeDisplay[$CurrentDuration],20]
	}],Spacer[1],
	Row[{Button[
		Dynamic[Switch[$CurrentStream[StatusAlias],
			"Playing",TextDict[["Pause"]],
			"Paused"|"Stopped",TextDict[["Play"]]
		]],
		Switch[$CurrentStream[StatusAlias],
			"Playing",$CurrentStream[StatusAlias]="Paused",
			"Paused"|"Stopped",$CurrentStream[StatusAlias]="Playing"
		],
		ImageSize->80],
		Spacer[20],
		Button[TextDict[["Stop"]],$CurrentStream[StatusAlias]="Stopped",ImageSize->80],
		Spacer[20],
		Button[TextDict[["Return"]],AudioStop[];DialogReturn[uiPlaylist[currentPlaylist]],ImageSize->80]			
	}]
}];


uiPlayerControlsNew := With[{StatusAlias = Thulium`System`Private`StatusAlias}, {
	Row[{
		Column[{Style[Dynamic[timeDisplay[$CurrentStream["Position"]]],20],Spacer[1]}],
		Spacer[8],
		Magnify[
			EventHandler[Dynamic@Graphics[{
				progressBar[$CurrentStream["Position"]/$CurrentDuration,16],
				progressBlock[$CurrentStream["Position"]/$CurrentDuration,16]
			}],
			{"MouseDragged":>(
				$CurrentStream["Position"]=$CurrentDuration*progressLocate[CurrentValue[{"MousePosition","Graphics"}][[1]],16]
			)}],
		3.6],
		Spacer[8],
		Column[{Style[timeDisplay[$CurrentDuration],20],Spacer[1]}]
	},ImageSize->Full,Alignment->Center],
	Row[{
		DynamicModule[{style="Default"},
			Dynamic@Switch[$CurrentStream[StatusAlias],
				"Playing",EventHandler[SmartButton["Pause",style],{
					"MouseDown":>(style="Clicked"),
					"MouseUp":>(style="Default";$CurrentStream[StatusAlias]="Paused")
				}],
				"Paused"|"Stopped",EventHandler[SmartButton["Play",style],{
					"MouseDown":>(style="Clicked"),
					"MouseUp":>(style="Default";$CurrentStream[StatusAlias]="Playing")
				}]
			]
		],
		Spacer[20],
		DynamicModule[{style="Default"},
			EventHandler[Dynamic@SmartButton["Stop",style],{
				"MouseDown":>(style="Clicked"),
				"MouseUp":>(style="Default";$CurrentStream[StatusAlias]="Stopped";$CurrentStream["Position"]=0)
			}]
		],
		Spacer[20],
		DynamicModule[{style="Default"},
			EventHandler[Dynamic@SmartButton["ArrowL",style],{
				"MouseDown":>(style="Clicked";),
				"MouseUp":>(style="Default";
					AudioStop[];
					DialogReturn[uiPlaylist[currentPlaylist]];
				)
			}]
		]		
	},ImageSize->{300,60},Alignment->Center]
}];
