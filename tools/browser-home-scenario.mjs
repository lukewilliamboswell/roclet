export default async function ({ evaluate, send }) {
  await evaluate(`(async () => {
    const html = await (await fetch(location.href)).text();
    const page = new DOMParser().parseFromString(html, 'text/html');
    const hero = page.querySelector('h1');
    if (!hero?.textContent.includes('Reactive notebooks') || !page.querySelector('[data-roc-frame]')) {
      throw new Error('Landing content and binding annotations must be present before JavaScript runs');
    }
    const demo = page.querySelector('a[href$="example=reactivity"]');
    if (!demo || !(await fetch(new URL(demo.getAttribute('href'), location.href))).ok) {
      throw new Error('Prerendered demo links must resolve under the site prefix');
    }
    const load = async () => {
      for (let i=0; i<200; i++) {
        if (document.querySelector('#recent-status')?.textContent.startsWith('No recent')) return;
        await new Promise(resolve => setTimeout(resolve, 20));
      }
      throw new Error('Signals homepage did not mount');
    };
    await load();
  })()`);
  const upload = (name, source) => evaluate(`(() => {
    const input = document.getElementById('open-notebook');
    const transfer = new DataTransfer();
    transfer.items.add(new File([${JSON.stringify(source)}], ${JSON.stringify(name)}));
    input.files = transfer.files;
    input.dispatchEvent(new Event('change', {bubbles: true}));
  })()`);
  await upload('invalid.txt', 'This is not a notebook.');
  await evaluate(`(async () => {
    for (let i=0; i<200; i++) {
      const input = document.getElementById('open-notebook');
      if (!input.disabled && !input.value && document.getElementById('open-status').textContent.includes('Choose a .roc')) return;
      await new Promise(resolve => setTimeout(resolve, 20));
    }
    throw new Error('File-open failure must be visible and the picker must be ready to retry');
  })()`);
  await send('Page.addScriptToEvaluateOnNewDocument', {source: "sessionStorage.setItem('lastNavigation', location.href)"});
  await upload('Homepage upload.md', '# Uploaded from the homepage');
  for (let i=0; i<200; i++) {
    try {
      const ready = await evaluate(`(async () => {
        if (!location.pathname.endsWith('/web/edit.html') || document.documentElement.dataset.startup !== 'ready') return false;
        const url = new URL(sessionStorage.getItem('lastNavigation'));
        const id = url.searchParams.get('notebook');
        if (!id) throw new Error('Homepage must navigate to the saved draft');
        const { DraftStore } = await import('./edit-store.mjs');
        const store = new DraftStore();
        const record = await store.get(id);
        store.close();
        return record?.source === '# Uploaded from the homepage';
      })()`);
      if (ready) return {result: 'pass', verified: 'prerender, prefixed links, failed open, file picker recovery and persisted draft navigation'};
    } catch (error) {
      if (!/context|navigat/i.test(error.message)) throw error;
    }
    await new Promise(resolve => setTimeout(resolve, 20));
  }
  throw new Error('Opening a notebook from the homepage did not reach the editor');
}
