import { readFile } from 'node:fs/promises';

export default async function ({ evaluate, send }) {
  for (let i=0; i<200; i++) {
    let atEditor = false;
    try {
      atEditor = await evaluate("location.pathname.endsWith('/web/edit.html') && document.documentElement.dataset.startup === 'ready'");
    } catch (error) {
      if (!/context|navigat/i.test(error.message)) throw error;
    }
    if (atEditor) {
      const binding = await evaluate("import('./edit.mjs').then(module => module.workbench().left.notebook.state.serverFile.path)");
      if (binding !== 'Notebook.roc') throw new Error('Expected the homepage to open the initial project file');
      const home = await evaluate("new URL('../?home=1', location.href).href");
      await send('Page.navigate', {url: home});
      for (let j=0; j<200; j++) {
        if (await evaluate("location.search === '?home=1' && Boolean(document.getElementById('app'))")) {
          return evaluate(await readFile(new URL('./local-project-browser.mjs', import.meta.url), 'utf8'));
        }
        await new Promise(resolve => setTimeout(resolve, 20));
      }
      throw new Error('The home override did not load the homepage');
    }
    await new Promise(resolve => setTimeout(resolve, 20));
  }
  throw new Error('The homepage did not open the initial local project notebook');
}
