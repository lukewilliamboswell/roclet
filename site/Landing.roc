import pf.Html

Landing := [].{
	header : {} -> Html.Markup(ctx)
	header = |_|
		\\<header>
		\\<a class="wordmark" href="./" aria-label="Roclet home">Roclet</a>
		\\<a class="repo" href="https://github.com/ageron/roclet">GitHub <span aria-hidden="true">↗</span></a></header>

	intro : {} -> Html.Markup(ctx)
	intro = |_|
		\\<div>
		\\<h1 id="welcome">Reactive notebooks<br>in Roc</h1>
		\\<p class="description">Write Roc code alongside notes, equations, and images. When you change a value, all dependent results update automatically.</p>
		\\<p class="description">Notebooks can also be run as regular Roc apps or exported as Markdown documents.</p></div>

	logo : {} -> Html.Markup(ctx)
	logo = |_|
		\\<img class="hero-logo" src="web/assets/roclet-logo-large.png" width="640" height="640" alt="Roclet’s purple and turquoise origami hummingbird" fetchpriority="high">

	recent_heading : {} -> Html.Markup(ctx)
	recent_heading = |_|
		\\<div class="section-heading">
		\\<h2 id="recent-heading"><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 5a2 2 0 0 1 2-2h13v18H6a2 2 0 0 1-2-2V5Zm0 12h15M8 7h7M8 11h5"/></svg>Recent notebooks</h2><span class="local-note">In this browser</span></div>

	demos : {} -> Html.Markup(ctx)
	demos = |_|
		\\<section aria-labelledby="demos-heading">
		\\<div class="section-heading">
		\\<h2 id="demos-heading"><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="3" y="3" width="18" height="18" rx="4"/><path d="m10 8 6 4-6 4V8Z"/></svg>Demos</h2></div>
		\\<ul class="demo-list">
		\\<li>
		\\<a href="web/edit.html?example=reactivity"><span><strong>Simple reactive notebook</strong><span class="detail">Change a value and see dependent cells recompute.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\<li>
		\\<a href="web/edit.html?example=coding-puzzle"><span><strong>Coding puzzle: longest streak</strong><span class="detail">Complete a function using the examples, checks, and hints.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\<li>
		\\<a href="web/edit.html?example=rich-outputs"><span><strong>Rich Outputs and Widgets</strong><span class="detail">Create Markdown, tables, images, and widgets that communicate with Roc.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\<li>
		\\<a href="web/edit.html?example=plume-charts"><span><strong>Interactive charts with Plume</strong><span class="detail">Plot a sine wave and change its frequency with a slider.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\<li>
		\\<a href="web/edit.html?example=csv-attachments"><span><strong>A café sales report from CSV</strong><span class="detail">Inspect an attachment, decode it with roc-parser, and replace the data.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\<li>
		\\<a href="web/edit.html?example=meeting-windows"><span><strong>Meeting scheduler with roc-time</strong><span class="detail">Find a shared meeting time using a Roc date and time package.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\<li>
		\\<a href="web/edit.html?example=gist-garden"><span><strong>A garden plan from a GitHub Gist</strong><span class="detail">A small notebook using a relative Roc package, supporting modules, and planting notes. Requires internet.</span></span><span class="arrow" aria-hidden="true">↗</span></a></li>
		\\</ul></section>

	uses : {} -> Html.Markup(ctx)
	uses = |_|
		\\<section class="uses" aria-labelledby="uses-heading">
		\\<h2 id="uses-heading"><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M9 18h6M10 21h4M8 14a6 6 0 1 1 8 0c-1 1-1 2-1 2H9s0-1-1-2Z"/></svg>What can you use it for?</h2>
		\\<dl class="use-list">
		\\<div>
		\\<dt><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M12 5c-3-2-6-2-9-1v15c3-1 6-1 9 1 3-2 6-2 9-1V4c-3-1-6-1-9 1Zm0 0v15"/></svg>Learning Roc</dt>
		\\<dd>Try expressions, inspect results, and keep notes next to the code.</dd></div>
		\\<div>
		\\<dt><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m5 3 14 9-7 1-3 7-4-17Zm9 12 4 5"/></svg>Learning interactively</dt>
		\\<dd>Explain a concept with text, equations, and code that readers can change.</dd></div>
		\\<div>
		\\<dt><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M4 3v17h17M8 15v-4M13 15V7M18 15v-6"/></svg>Data exploration</dt>
		\\<dd>Transform data and compare results as you refine your calculations.</dd></div>
		\\<div>
		\\<dt><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="m12 2 9 5v10l-9 5-9-5V7l9-5Zm-9 5 9 5 9-5M12 12v10M7.5 4.5l9 5"/></svg>Exploring Roc packages</dt>
		\\<dd>Import a package and try its functions in a notebook, with examples you can save and share.</dd></div>
		\\<div>
		\\<dt><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><path d="M5 3h10l4 4v14H5V3Zm10 0v5h4M8 11h7m-5 3-2 2 2 2m4-4 2 2-2 2"/></svg>Literate programming</dt>
		\\<dd>Keep explanations beside production code and save the notebook as a runnable Roc script.</dd></div>
		\\</dl>
		\\</section>

	platforms : {} -> Html.Markup(ctx)
	platforms = |_|
		\\<section class="platforms" aria-labelledby="platforms-heading">
		\\<h2 id="platforms-heading"><svg class="section-icon" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="1.7" stroke-linecap="round" stroke-linejoin="round" aria-hidden="true"><rect x="8" y="3" width="8" height="6" rx="1"/><rect x="2" y="16" width="8" height="5" rx="1"/><rect x="14" y="16" width="8" height="5" rx="1"/><path d="M12 9v4M6 16v-3h12v3"/></svg>Planned platforms</h2>
		\\<p>We plan to add Roclet platforms for specific uses, such as turtle graphics for teaching programming and tools for creating and testing web services. Each platform would provide the capabilities and interface that suit the task.</p></section>

	install : {} -> Html.Markup(ctx)
	install = |_|
		\\<section class="platforms" aria-labelledby="install-heading">
		\\<h2 id="install-heading">Prefer running your own server?</h2>
		\\<p>Most people can use Roclet right here. For a local copy, download the optional server for macOS, Windows, or Linux.</p>
		\\<a href="web/install.html">Install the Roclet server <span aria-hidden="true">→</span></a></section>

	footer : {} -> Html.Markup(ctx)
	footer = |_|
		\\<footer><span>Built with <a href="https://www.roc-lang.org/">Roc</a>.</span>
		\\<a href="https://github.com/ageron/roclet/issues">Report an issue <span aria-hidden="true">↗</span></a></footer>
}
