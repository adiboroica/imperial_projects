import { createSlice } from '@reduxjs/toolkit';


export interface WsState {
  isEstablishingConnection: boolean;
  isConnected: boolean;
}

const initialState: WsState = {
  isEstablishingConnection: false,
  isConnected: false
};


const wsSlice = createSlice({
  name: 'ws',
  initialState,
  reducers: {
    startConnecting: (state => {
      state.isEstablishingConnection = true;
    }),
    connectionEstablished: (state => {
      state.isConnected = true;
      state.isEstablishingConnection = true;
    }),
    disconnected: (state => {
      state.isConnected = false;
      state.isEstablishingConnection = false;
    }),
  },
});

export const {
  startConnecting,
  connectionEstablished,
  disconnected,
} = wsSlice.actions;


export default wsSlice.reducer;