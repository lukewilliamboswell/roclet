import pf.Engine
import pf.Html
import pf.Port
import pf.Web
import Landing

Home := [].{
	Recent : { id : Str, title : Str, href : Str, edited : Str, date_time : Str }
	ProjectEntry : { path : Str, href : Str }
	Project : [NoProject, OpenProjectFile(Str), ProjectFiles({ root : Str, entries : List(ProjectEntry) }), ProjectFailed(Str)]
	Navigation : { href : Str, replace : Bool }
	OpenResult : [Opened(Str), OpenFailed(Str)]

	Ports : {
		list : Port.Call({}, List(Recent)),
		refresh : Port.Subscription({}, {}),
		remove : Port.Call(Str, {}),
		open : Port.Call(Engine.File, OpenResult),
		project : Port.Call({}, Project),
		navigate : Port.Command(Navigation),
	}

	ports : Ports
	ports = {
		list: Port.call({ name: "roclet/home/list-recents" }),
		refresh: Port.subscription({ name: "roclet/home/refresh", delivery: Latest }),
		remove: Port.call({ name: "roclet/home/remove-recent" }),
		open: Port.call({ name: "roclet/home/open-file" }),
		project: Port.call({ name: "roclet/home/project" }),
		navigate: Port.command({ name: "roclet/home/navigate" }),
	}

	registrations = Port.registrations(Home.ports)

	Model : {
		recents : List(Recent),
		expanded : Bool,
		refresh : U64,
		recent_status : Str,
		removing : Bool,
		remove : Engine.Outbox(Str),
		opening : Bool,
		open : Engine.Outbox(Engine.File),
		open_status : Str,
		project : Project,
		focus : Engine.Outbox(Str),
		navigate : Engine.Outbox(Navigation),
	}

	Ctx : Engine.In(Engine.Root, Model)
	State : Engine.State(Ctx, Model)

	empty_recents = "No recent notebooks. Create a notebook or open a demo to get started."
	open_ref = "open-notebook"

	initial : Model
	initial = {
		recents: [],
		expanded: False,
		refresh: 0,
		recent_status: "Loading recent notebooks…",
		removing: False,
		remove: Engine.outbox({}),
		opening: False,
		open: Engine.outbox({}),
		open_status: "",
		project: NoProject,
		focus: Engine.outbox({}),
		navigate: Engine.outbox({}),
	}

	visible : Model -> List(Recent)
	visible = |model| if (model.expanded) model.recents else model.recents.take_first(6)

	recent_status : List(Recent) -> Str
	recent_status = |recents| if (recents.is_empty()) Home.empty_recents else ""

	remove_ref : Str -> Str
	remove_ref = |id| "remove-recent-${id}"

	removed : Model, Str, Try({}, Port.Error) -> Model
	removed = |model, id, result| match result {
		Err(_) => { ..model, removing: False, recent_status: "Could not remove this notebook from recent history. Please try again." }
		Ok(_) => {
			index = Home.visible(model).find_first_index(|recent| recent.id == id) ?? 0
			recents = model.recents.drop_if(|recent| recent.id == id)
			updated = { ..model, recents, recent_status: Home.recent_status(recents), removing: False, refresh: model.refresh + 1 }
			remaining = Home.visible(updated)
			target = if (remaining.is_empty()) Home.open_ref else {
				recent = remaining.get(if (index < remaining.len()) index else remaining.len() - 1) ?? crash "A visible recent notebook was expected"
				Home.remove_ref(recent.id)
			}
			{ ..updated, focus: updated.focus.post(target) }
		}
	}

	file_selected : Model, Engine.Received -> Model
	file_selected = |model, received| {
		if (model.opening) return model
		match received.files.first() {
			Ok(file) => { ..model, open: model.open.post(file), opening: True, open_status: "Opening notebook…" }
			Err(_) => model
		}
	}

	file_opened : Model, Engine.File, Try(OpenResult, Port.Error) -> Model
	file_opened = |model, _, result| match result {
		Ok(Opened(href)) => { ..model, navigate: model.navigate.post({ href, replace: False }) }
		Ok(OpenFailed(message)) => { ..model, opening: False, open_status: message }
		Err(_) => { ..model, opening: False, open_status: "Could not open this notebook." }
	}

	effects : State -> List(Engine.Elem(Ctx))
	effects = |state| {
		model = state.signal()
		[
			Engine.watch(Engine.const({}), |_| [Home.ports.refresh.ask({})], state.on_result(|current, _, _| { ..current, refresh: current.refresh + 1 })),
			Engine.watch_latest(
				model.map(|current| current.refresh),
				|_| [Home.ports.list.ask({})],
				state.on_result(
					|current, _, result| match result {
						Ok(recents) => { ..current, recents, recent_status: Home.recent_status(recents) }
						Err(_) => { ..current, recents: [], recent_status: "Recent notebooks are unavailable because this browser could not open its storage. You can still try a demo." }
					},
				),
			),
			Engine.on_post(model.map(|current| current.remove), |id| [Home.ports.remove.ask(id)], state.on_result(Home.removed)),
			Engine.on_post(model.map(|current| current.open), |file| [Home.ports.open.ask(file)], state.on_result(Home.file_opened)),
			Engine.watch(
				Engine.const({}),
				|_| [Home.ports.project.ask({})],
				state.on_result(
					|current, _, result| match result {
						Ok(OpenProjectFile(href)) => { ..current, navigate: current.navigate.post({ href, replace: True }) }
						Ok(project) => { ..current, project }
						Err(_) => { ..current, project: ProjectFailed("Could not list project notebooks.") }
					},
				),
			),
			Engine.on_post(model.map(|current| current.focus), |name| [Engine.command(Focus(name))], Engine.ignore({})),
			Engine.on_post(model.map(|current| current.navigate), |job| [Engine.command(Home.ports.navigate.send(job))], Engine.ignore({})),
		]
	}

	status : Str, Str, Engine.Signal(Ctx, Str) -> Engine.Elem(Ctx)
	status = |id, class, message| Html.p_s(
		message,
		[
			Engine.attr("id", id),
			Engine.class(class),
			Engine.attr("role", "status"),
			Html.hidden_s(message.map(|value| if (value.is_empty()) Hidden else Shown)),
		],
	)

	hero : State -> Engine.Elem(Ctx)
	hero = |state| {
		model = state.signal()
		new_notebook : Html.Markup(Ctx)
		new_notebook = "<a class='primary' href='web/edit.html?new=1'><span aria-hidden='true'>＋</span> New notebook</a>"
		Engine.element(
			"section",
			[Engine.class("hero"), Engine.attr("aria-labelledby", "welcome")],
			[
				Html.div(
					"intro",
					[
						Landing.intro({}).to_elem(),
						Html.div(
							"home-actions",
							[
								new_notebook.to_elem(),
								Engine.element(
									"label",
									[
										Engine.class("secondary home-file-button"),
										Engine.attr_s("aria-disabled", model.map(|current| if (current.opening) "true" else "false")),
									],
									[
										Engine.text("Open notebook…"),
										Engine.element(
											"input",
											[
												Engine.attr("id", Home.open_ref),
												Engine.attr("type", "file"),
												Engine.attr("accept", ".roc,.md,.roclet.zip,.zip"),
												Engine.attr("aria-label", "Open notebook"),
												Engine.ref(Home.open_ref),
												Html.disabled(model.map(|current| current.opening)),
												Engine.on_files(Change, state.set_value(Home.file_selected)),
											],
											[],
										),
									],
								),
							],
						),
						Home.status("open-status", "quiet", model.map(|current| current.open_status)),
						Html.p("Runs in your browser, with no installation or account required.", "quiet"),
					],
				),
				Landing.logo({}).to_elem(),
			],
		)
	}

	checked_href : Str -> [Absent, Present(Web.Link)]
	checked_href = |href| match Web.Link.from_str(href) {
		Ok(link) => Present(link)
		Err(_) => Absent
	}

	recent_list : State -> Engine.Elem(Ctx)
	recent_list = |state| {
		model = state.signal()
		Engine.element(
			"section",
			[Engine.attr("aria-labelledby", "recent-heading")],
			[
				Landing.recent_heading({}).to_elem(),
				Home.status("recent-status", "empty", model.map(|current| current.recent_status)),
				Engine.element(
					"ul",
					[Engine.attr("id", "recents"), Engine.class("recent-list")],
					[
						Engine.each(
							model.map(Home.visible),
							|recent| recent.id,
							|row| {
								title = row.field(|recent| if (recent.title.is_empty()) "Untitled" else recent.title)
								remove = state.lift_row().update_by(row.key(), |current, id|
									{ ..current, removing: True, remove: current.remove.post(id) })
								Engine.element(
									"li",
									[Engine.class("recent-row")],
									[
										Engine.element(
											"a",
											[Html.href_s(row.field(|recent| Home.checked_href(recent.href)))],
											[
												Engine.element(
													"span",
													[],
													[
														Engine.element("strong", [], [Engine.text_s(title)]),
														Engine.element(
															"time",
															[Engine.attr_s("datetime", row.field(|recent| recent.date_time))],
															[
																Engine.text_s(row.field(|recent| recent.edited)),
															],
														),
													],
												),
												Engine.element("span", [Engine.class("arrow"), Engine.attr("aria-hidden", "true")], [Engine.text("→")]),
											],
										),
										Engine.element(
											"button",
											[
												Engine.class("remove-recent"),
												Engine.attr("type", "button"),
												Engine.attr("title", "Remove from recent notebooks"),
												Engine.attr_s("aria-label", title.map(|name| "Remove ${name} from recent notebooks")),
												Engine.ref_s(row.key().map(Home.remove_ref)),
												Html.disabled(model.lift_row().map(|current| current.removing)),
												Engine.on_click(remove),
											],
											[Engine.text("×")],
										),
									],
								)
							},
						),
					],
				),
				Engine.element(
					"button",
					[
						Engine.attr("id", "show-all"),
						Engine.class("text-button"),
						Engine.attr("type", "button"),
						Html.hidden_s(model.map(|current| if (current.recents.len() <= 6) Hidden else Shown)),
						Engine.on_click(state.update(|current| { ..current, expanded: !current.expanded })),
					],
					[Engine.text_s(model.map(|current| if (current.expanded) "Show fewer" else "Show all ${current.recents.len().to_str()} notebooks"))],
				),
			],
		)
	}

	project_list : State -> Engine.Elem(Ctx)
	project_list = |state| {
		project = state.signal().map(|current| current.project)
		Engine.when(
			project.map(
				|value| match value {
					ProjectFiles(_) | ProjectFailed(_) => True
					_ => False
				},
			),
			|| {
				entries = project.map(
					|value| match value {
						ProjectFiles(files) => files.entries
						_ => []
					},
				)
				Engine.element(
					"section",
					[
						Engine.attr("aria-labelledby", "project-heading"),
					],
					[
						Engine.element("h2", [Engine.attr("id", "project-heading")], [Engine.text("Project notebooks")]),
						Html.p_s(
							project.map(
								|value| match value {
									ProjectFiles(files) => files.root
									ProjectFailed(message) => message
									_ => ""
								},
							),
							[],
						),
						Engine.element(
							"ul",
							[Engine.class("recent-list")],
							[
								Engine.each(
									entries,
									|entry| entry.path,
									|row| Engine.element(
										"li",
										[],
										[
											Engine.element("a", [Html.href_s(row.field(|entry| Home.checked_href(entry.href)))], [Engine.text_s(row.key())]),
										],
									),
								),
							],
						),
						Home.status(
							"project-empty",
							"",
							project.map(
								|value| match value {
									ProjectFiles(files) if files.entries.is_empty() => "No notebooks here yet. Create one above and use Save to choose its filename."
									_ => ""
								},
							),
						),
					],
				)
			},
			|| Engine.text(""),
		)
	}

	view : State -> Engine.Elem(Ctx)
	view = |state| Html.div(
		"page",
		[
			Landing.header({}).to_elem(),
			Engine.element(
				"main",
				[],
				[
					Home.hero(state),
					Home.project_list(state),
					Html.div("workspace", [Home.recent_list(state), Landing.demos({}).to_elem()]),
					Landing.uses({}).to_elem(),
					Landing.platforms({}).to_elem(),
					Landing.install({}).to_elem(),
				],
			),
			Landing.footer({}).to_elem(),
		].concat(Home.effects(state)),
	)
}
