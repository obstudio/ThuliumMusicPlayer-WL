(* ::Package:: *)

qymPlay[filename_,default_]:=Module[
	{
		i,j,
		data,char,music={},
		tonality=0,beat=1,speed=88,instrument,
		pitch,sharp=0,time,space,tercet=0,tercetTime,
		comment,match,timeDot,note,duration,frequency,
		tonalityDict=<|
			"C"->0,"G"->7,"D"->2,"A"->-3,"E"->4,
			"B"->-1,"#F"->6,"#C"->1,"F"->5,"bB"->-2,
			"bE"->3,"bA"->-4,"bD"->1,"bG"->6,"bC"->-1
		|>,
		pitchDict=<|"1"->0,"2"->2,"3"->4,"4"->5,"5"->7,"6"->9,"7"->11|>
	},
	instrument=default[[1]];
	data=#[[1]]&/@Import[filename,"Table"];
	Do[
		j=1;
		While[j<=StringLength[data[[i]]],
			char=StringTake[data[[i]],{j}];
			Switch[char,
				"/",
					If[StringTake[data[[i]],{j+1}]=="/",Break[]],
				"#",
					sharp++;
					j++;
					Continue[],
				"b",
					sharp--;
					j++;
					Continue[],
				"<",
					match=Select[Transpose[StringPosition[data[[i]],">"]][[1]],#>j&][[1]];
					comment=StringTake[data[[i]],{j+1,match-1}];
					Switch[StringTake[comment,{2}],
						"=",
							tonality=tonalityDict[[StringTake[comment,{3,StringLength@comment}]]],
						"/",
							beat=ToExpression[StringTake[comment,{3}]]/4,
						_,
							speed=ToExpression[comment];
					];
					j=match+1;
					Continue[],
				"(",
					match=Select[Transpose[StringPosition[data[[i]],")"]][[1]],#>j&][[1]];
					comment=StringTake[data[[i]],{j+1,match-1}];
					tercet=ToExpression[comment];
					tercetTime=(2^Floor[Log2[tercet]])/tercet;
					j=match+1;
					Continue[],
				"{",
					match=Select[Transpose[StringPosition[data[[i]],"}"]][[1]],#>j&][[1]];
					instrument=StringTake[data[[i]],{j+1,match-1}]
			];
			If[MemberQ[{"0","1","2","3","4","5","6","7"},char],
				note=ToExpression@char;
				time=1;
				space=True;
				pitch=If[note==0,None,pitchDict[[note]]+tonality+sharp];
				sharp=0;
				j++;
				While[j<=StringLength[data[[i]]] && MemberQ[{"-","_","'",",",".","^"},StringTake[data[[i]],{j}]],
					char=StringTake[data[[i]],{j}];
					Switch[char,
						"-",time+=1,
						"_",time/=2,
						"'",pitch+=12,
						",",pitch-=12,
						".",
							timeDot=1/2;
							While[j<=StringLength[data[[i]]] && StringTake[data[[i]],{j+1}]==".",
								timeDot/=2;
								j++;
							];
							time*=(2-timeDot),
						"^",space=False
					];
					j++;
				];
				If[tercet>0,
					time*=tercetTime;
					tercet--;
				];
				duration=60/speed*time*beat;
				If[instrument=="Sine",
					frequency=If[pitch===None,0,440*2^((pitch-9)/12)];
					If[space,
						EmitSound@Play[Sin[frequency*2*Pi*t],{t,0,duration*7/8}];
						EmitSound@Play[0,{t,0,duration/8}],
						EmitSound@Play[Sin[frequency*2*Pi*t],{t,0,duration}];
					],
					If[space,
						AppendTo[music,SoundNote[pitch,duration*7/8,instrument]];
						AppendTo[music,SoundNote[None,duration/8]],
						AppendTo[music,SoundNote[pitch,duration,instrument]];
					]
				],
			j++];
		],
	{i,Length[data]}];
	If[music!={},EmitSound@Sound@music];
]
