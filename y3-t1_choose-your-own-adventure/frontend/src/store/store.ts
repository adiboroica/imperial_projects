import { configureStore } from '@reduxjs/toolkit'
import accountReducer from './features/accountSlice'
import initialInputReducer from './features/initialInputSlice'
import storyReducer from './features/storySlice'
import wsMiddleware from './wsMiddleware'
import wsReducer from './wsSlice'

const reducer = {
  story: storyReducer,
  account: accountReducer,
  initialInput: initialInputReducer,
  ws: wsReducer,
}

export const store = configureStore({
  reducer,
  middleware: (getDefaultMiddleware) => {
    return getDefaultMiddleware().concat(wsMiddleware);
  },
});

export type RootState = ReturnType<typeof store.getState>;
export type AppDispatch = typeof store.dispatch;
