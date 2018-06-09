import _ from 'lodash';
import Vue from 'vue/dist/vue.esm';
import VueRouter from 'vue-router';
import web3Helper from 'web3-helper';
import utils from '../utils';

import VueProgressBar from 'vue-progressbar'
import NoMetaMask from '../components/no-metamask';
import TopMenu from '../components/top-menu';
import SideMenu from '../components/side-menu';
import App from '../components/app';
import NotFound from '../components/not-found';
import Game from '../components/game';
import GameForm from '../components/game-form';
import Games from '../components/games';
import GamesNew from '../components/games-new';

global.web3Helper = web3Helper;

$(() => {
  web3Helper.checkMetamask(4);

  toastr.options.positionClass = 'toast-top-center';
  window.ttr = toastr;
  const csrfToken = $("meta[name=csrf-token]").attr("content");

  Vue.use(VueRouter);
  Vue.use(VueProgressBar, {
    autoFinish: false
  });

  // register components
  Vue.component('top-menu', TopMenu);
  Vue.component('side-menu', SideMenu);
  Vue.component('game', Game);
  Vue.component('game-form', GameForm);

  global.vm = new Vue({
    el: '#vueRoot',
    router: new VueRouter({
      routes: [{
        path: '/',
        component: web3 ? App : NoMetaMask,
        children: [{
            path: '',
            component: {
              template: '<div class="h1 jumbotron text-center">App</div>'
            }
          },
          {
            path: 'not-found',
            component: NotFound
          },
          {
            path: 'games',
            component: Games
          },
          {
            path: 'games/new',
            component: GamesNew,
            props: {
              csrfToken
            }
          },
        ]
      }]
    })
  });
});