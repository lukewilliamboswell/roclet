import { DraftStore } from './edit-store.mjs';
import { serverProjectReady } from './server-project.mjs';

const store = new DraftStore();
const dates = new Intl.DateTimeFormat(undefined, { month: 'short', day: 'numeric', year: 'numeric' });
const editorLink = (key, value) => `web/edit.html?${key}=${encodeURIComponent(value)}`;
const draftSummary = record => {
  const updated = new Date(record.updatedAt);
  const hasDate = Number.isFinite(updated.getTime());
  return {
    id: record.id,
    title: record.title,
    href: editorLink('notebook', record.id),
    edited: hasDate ? `Edited ${dates.format(updated)}` : '',
    date_time: hasDate ? updated.toISOString() : '',
  };
};

export default {
  'roclet/home/list-recents': {
    call: async () => (await store.list())
      .filter(record => record.schema === 1 && typeof record.id === 'string'
        && typeof record.title === 'string' && Array.isArray(record.cells))
      .map(draftSummary),
  },
  'roclet/home/refresh': {
    subscribe: (_, { emit }) => {
      const refresh = () => emit({});
      addEventListener('pageshow', refresh);
      addEventListener('focus', refresh);
      return () => {
        removeEventListener('pageshow', refresh);
        removeEventListener('focus', refresh);
      };
    },
  },
  'roclet/home/remove-recent': {
    call: id => store.removeFromRecents(id),
  },
  'roclet/home/open-file': {
    call: async file => {
      // The event already captured the File. Reset the picker so the user
      // can choose the same file again after a failed import.
      document.getElementById('open-notebook').value = '';
      try {
        const { openNotebookFile } = await import('./open-notebook.mjs');
        const url = await openNotebookFile(file, store, async () => {
          const response = await fetch('artifacts/manifest.json');
          if (!response.ok) throw new Error('Could not load Roclet’s compiler information. Please try again.');
          return response.json();
        });
        return { Opened: url };
      } catch (error) {
        return { OpenFailed: error.message || 'Could not open this notebook.' };
      }
    },
  },
  'roclet/home/project': {
    call: async () => {
      const project = await serverProjectReady;
      if (!project) return 'NoProject';
      if (project.config.initial && !new URL(location.href).searchParams.has('home')) {
        return { OpenProjectFile: editorLink('file', project.config.initial) };
      }
      try {
        const { paths } = await project.call('list');
        return { ProjectFiles: {
          root: project.config.root,
          entries: paths.sort().map(path => ({ path, href: editorLink('file', path) })),
        } };
      } catch (error) {
        return { ProjectFailed: error.message };
      }
    },
  },
  'roclet/home/navigate': {
    command: ({ href, replace }) => {
      if (replace) location.replace(href);
      else location.assign(href);
    },
  },
};
