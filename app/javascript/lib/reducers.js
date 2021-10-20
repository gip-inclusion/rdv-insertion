function initReducer(items) {
  return items || [];
}

function reducerFactory() {
  return function reducer(state, action) {
    switch (action.type) {
      case "append":
        return [action.item, ...state];
      case "update": {
        const elIndex = state.findIndex((el) => el.seed === action.item.seed);
        const updatedState = state;
        updatedState[elIndex] = { ...state[elIndex], ...action.item };
        return updatedState;
      }
      case "replace":
        return action.items;
      case "reset":
        return initReducer(action.items);
      default:
        throw new Error();
    }
  };
}

export { initReducer, reducerFactory };
