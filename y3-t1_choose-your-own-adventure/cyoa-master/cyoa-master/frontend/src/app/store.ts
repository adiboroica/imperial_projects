import { configureStore } from '@reduxjs/toolkit'
import inputTextReducer from '../features/text/inputTextSlice'
import storyReducer from '../features/text/storySlice'

const reducer = {
  inputText: inputTextReducer,
  story: storyReducer,
}

export const store = configureStore({
  reducer,
});

// Infer the `RootState` and `AppDispatch` types from the store itself
export type RootState = ReturnType<typeof store.getState>;
// Inferred type: {posts: PostsState, comments: CommentsState, users: UsersState}
export type AppDispatch = typeof store.dispatch;
